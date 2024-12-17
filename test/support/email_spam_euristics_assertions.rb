module EmailSpamEuristicsAssertions
  def refute_email_spammyness(email)
    assert_subject_length_is_between_30_and_50_chars(email)
    assert_body_does_not_contains_upcase_word(email)
  end

  private

  def assert_subject_length_is_between_30_and_50_chars(email)
    assert(email.subject.size >= 30 && email.subject.size <= 50,
           "woops, too long subject [30<=#{email.subject.size}>=50]: #{email.subject}")
  end

  def assert_body_does_not_contains_upcase_word(email)
    white_list = %w(DNE Direction Numérique Éducation)

    nokogiri_doc = Nokogiri::HTML(email.html_part.body.to_s)
    text_nodes = nokogiri_doc.search('//text()')
                             .reject{|el| el.is_a?(Nokogiri::XML::CDATA) }
    upcase_words = text_nodes.map(&:text)
                              .map { |sentence|
                                white_list.each do |white_word|
                                  sentence.gsub!(white_word, '')
                                end
                              }.grep(/([[:upper:]]){2,}/)
    upcase_words = upcase_words.map(&:strip)
                               .reject(&:empty?)
    assert(upcase_words.size.zero?,
           "whoops, what happens there is an upcase word: #{upcase_words.join("\n")}")
  end
end
