require 'net/http'
require 'json'
require 'uri'
require 'pretty_console'
require 'csv'

namespace :crisp do
  desc 'Fetch all conversations and their messages from Crisp API and save to CSV'
  task fetch_conversations: :environment do |task|
    PrettyConsole.announce_task(task) do
      website_id = ENV['CRISP_WEBSITE_ID']
      api_identifier = ENV['CRISP_TOKEN']
      api_key = ENV['CRISP_API_KEY']

      if [website_id, api_identifier, api_key].any?(&:nil?)
        PrettyConsole.say_in_red 'Crisp ENV variables not found.'
        PrettyConsole.say_in_red 'Please set CRISP_WEBSITE_ID, CRISP_TOKEN, and CRISP_API_KEY.'
        next
      end

      base_uri = "https://api.crisp.chat/v1/website/#{website_id}"
      page_number = 0
      total_conversations = 0
      total_messages = 0

      csv_file_path = Rails.root.join('tmp', 'crisp_messages.csv')
      csv_headers = %w[conversation_id timestamp author recipient message]

      CSV.open(csv_file_path, 'w', write_headers: true, headers: csv_headers) do |csv|
        loop do
          conversations_uri = URI("#{base_uri}/conversations/#{page_number}")
          PrettyConsole.say_in_yellow "Fetching conversations from page #{page_number}..."

          http = Net::HTTP.new(conversations_uri.host, conversations_uri.port)
          http.use_ssl = true

          request = Net::HTTP::Get.new(conversations_uri)
          request.basic_auth(api_identifier, api_key)
          request['X-Crisp-Tier'] = 'plugin'

          response = http.request(request)

          unless response.is_a?(Net::HTTPSuccess)
            PrettyConsole.say_in_red "Error fetching conversations: #{response.code} #{response.message}"
            break
          end

          conversations = JSON.parse(response.body)['data']
          break if conversations.empty?

          PrettyConsole.say_in_green "Found #{conversations.count} conversations on page #{page_number}."

          conversations.each do |conversation|
            session_id = conversation['session_id']
            user_nickname = conversation.dig('meta', 'nickname') || 'Unknown User'
            total_conversations += 1
            PrettyConsole.say_in_cyan "  -> Processing conversation #{session_id} for user '#{user_nickname}'"

            messages_uri = URI("#{base_uri}/conversation/#{session_id}/messages")
            msg_request = Net::HTTP::Get.new(messages_uri)
            msg_request.basic_auth(api_identifier, api_key)
            msg_request['X-Crisp-Tier'] = 'plugin'

            msg_response = http.request(msg_request)

            if msg_response.is_a?(Net::HTTPSuccess)
              messages = JSON.parse(msg_response.body)['data']
              total_messages += messages.count
              PrettyConsole.say_in_green "     Found #{messages.count} messages. Writing to CSV..."

              messages.each do |message|
                timestamp = Time.at(message['timestamp']).to_s
                content = message['content']
                content = content.to_json if content.is_a?(Hash) || content.is_a?(Array)

                author = message.dig('user', 'nickname') || 'Unknown Sender'
                recipient = message['from'] == 'operator' ? user_nickname : 'Support Team'

                csv << [session_id, timestamp, author, recipient, content]
              end
            else
              PrettyConsole.say_in_red "     Error fetching messages: #{msg_response.code} #{msg_response.message}"
            end

            # Avoid hitting API rate limits
            sleep(0.5)
          end

          page_number += 1
          sleep(1)
        end
      end

      PrettyConsole.say_in_green '--------------------------------'
      PrettyConsole.say_in_green "Total conversations processed: #{total_conversations}"
      PrettyConsole.say_in_green "Total messages found: #{total_messages}"
      PrettyConsole.say_in_green "All messages have been saved to: #{csv_file_path}"
    end
  end
end
