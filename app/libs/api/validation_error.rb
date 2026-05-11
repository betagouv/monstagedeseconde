module Api
  class ValidationError < StandardError
    attr_reader :code, :error_message, :status

    def initialize(code:, error:, status:)
      @code = code
      @error_message = error
      @status = status
      super(error)
    end
  end
end
