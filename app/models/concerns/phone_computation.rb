
module PhoneComputation
  extend ActiveSupport::Concern

  included do
    def compute_mobile_phone_prefix
      # Users::Student.kept.where.not(phone: nil).where.not(phone: '').first(10000).pluck(:phone).map do |phone|
      #   phone[0..4]
      # end.uniq ==> ["+3307", "+3306", "+2620", "+5960", "+5940"]
      return nil if phone.blank?

      bare_prefix = phone[0..4]
      french_prefix = %w(+3306 +3307 +2620 +5960 +5940 +6870 +6890)
      return nil unless bare_prefix.in?(french_prefix)

      bare_prefix.in?(%w(+3306 +3307)) ? '33' : bare_prefix[1..-2]
    end

    def formatted_phone
      return if phone.blank?

      phone[0..4].gsub('0', '') + phone[5..]
    end

    def self.sanitize_mobile_phone_number(number, prefix = '')
      return nil if number.blank?

      thin_number = number.gsub(/[\s|;\,\.\:\(\)]/, '')
      if thin_number.match?(/\A\+(33|262|594|596|687|689)0[6|7]\d{8}\z/)
        "#{prefix}#{thin_number[4..]}"
      elsif thin_number.match?(/\A\+(33|262|594|596|687|689)[6|7]\d{8}\z/)
        "#{prefix}#{thin_number[3..]}"
      elsif thin_number.match?(/\A(33|262|594|596|687|689)[6|7]\d{8}\z/)
        "#{prefix}#{thin_number[2..]}"
      elsif thin_number.match?(/\A(33|262|594|596|687|689)0[6|7]\d{8}\z/)
        "#{prefix}#{thin_number[3..]}"
      elsif thin_number.match?(/\A0[6|7]\d{8}\z/)
        "#{prefix}#{thin_number[1..]}"
      else
        nil
      end
    end

    def concatenate_and_clean
      # if prefix and suffix phone are given,
      # this means an update temptative
      if phone_prefix.present? && !phone_suffix.nil?
        self.phone = "#{phone_prefix}#{phone_suffix}".gsub(/\s+/, '')
        self.phone_prefix = nil
        self.phone_suffix = nil
      end
      clean_phone
    end

    def clean_phone
      self.phone = phone.delete(' ') unless phone.nil?
      self.phone = nil if phone == '+33'
    end
  end
end