class MessageBox
  TYPES = %w[info error clear header temporaire].freeze # headers are never removed

  def add_message(message_content:, time_value: 0, type: 'info')
    check_values(message_content: message_content, time_value: time_value, type: type)

    time_value = last_time_value + time_value
    if type == 'error'
      # @messages = keep_error_and_show_errors
      time_value = 0
    elsif type == 'clear'
      @messages = clear_infos
    else
      @messages = clear_temporaries
    end
    @messages << { message_content: message_content, time_value: time_value, type: type }
  end

  def new_header(message_content)
    add_message(message_content: 'no content', type: 'clear')
    add_message(message_content: message_content, type: 'header')
    broadcast_progress
  end

  def broadcast_info(message_content:, time_value: 0)
    add_message(message_content: message_content, time_value: time_value, type: 'info')
    broadcast_progress
  end

  def broadcast_temporary_info(message_content:)
    add_message(message_content: message_content, time_value: 0, type: 'temporaire')
    broadcast_progress
  end

  def broadcast_error(message_content:)
    add_message(message_content: message_content, time_value: 0, type: 'error')
    broadcast_progress
  end

  def broadcast_progress
    ActionCable.server.broadcast(
      "progress_#{@job_id}",
      { progress: messages }
    )
  end

  def last_time_value
    @messages.last ? @messages.last[:time_value] : 0
  end

  attr_reader :messages

  private

  def check_values(message_content:, time_value:, type:)
    raise ArgumentError, 'message_content must be a String' unless message_content.is_a?(String)
    raise ArgumentError, "Type must be 'info', 'error', 'temporaire', or 'clear'" unless type.in?(TYPES)

    unless time_value.is_a?(Numeric) && time_value >= 0 && time_value <= 100
      raise ArgumentError,
            'Time value must be a Numeric'
    end
  end

  def clear_infos
    @messages = @messages.select { |msg| msg[:type] == 'header' }
  end

  def clear_temporaries
    @messages = @messages.reject { |msg| msg[:type] == 'temporaire' }
  end

  def keep_error_and_show_errors
    @messages # = @messages.select { |msg| msg[:type] == 'error' }
  end

  def initialize(job_id:)
    @job_id = job_id
    @messages = []
  end
end
