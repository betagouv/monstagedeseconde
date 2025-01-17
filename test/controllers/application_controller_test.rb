require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test '#strip_content' do
    controller = ApplicationController.new
    string = "<p>  Hello  </p>  \n<p>  World  </p>"
    assert_equal "Hello\nWorld", controller.send(:strip_content, string)
  end
end
