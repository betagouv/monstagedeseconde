class SendSmsJob < ApplicationJob
  queue_as :default

  def perform(user:, message:, phone_number: nil, campaign_name: nil)
    return if phone_number.nil? && user.phone.blank?

    if message.blank?
      Rails.logger.error('SMS: Message is just blank')
      return
    end
    if message&.length&.> 318
      Rails.logger.error("SMS: Message is too long: #{message}")
      return
    end
    if campaign_name&.size.to_i > 49
      Rails.logger.error("Campaign name is too long: #{campaign_name}")
      return
    end
    phone = phone_number || User.sanitize_mobile_phone_number(user.phone, user.compute_mobile_phone_prefix)

    Services::SmsSender.new(phone_number: phone, content: message, campaign_name:)
                       .perform
  end
end
