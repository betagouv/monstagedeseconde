FactoryBot.define do
  factory :inappropriate_offer do
    internship_offer 
    ground { :suspicious_content }
    details { "MyText is long enough" }
  end
end
  