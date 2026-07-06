module ReviewRebuild
  module CleaningCreationSteps # and Users::Operators
    extend ActiveSupport::Concern

    def create_cleaning
      if defined?(::MailActionItem)
        ::MailActionItem.delete_all
      end
    end
  end
end
