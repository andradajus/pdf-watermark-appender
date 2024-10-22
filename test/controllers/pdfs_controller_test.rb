require "test_helper"

class PdfsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get pdfs_new_url
    assert_response :success
  end

  test "should get create" do
    get pdfs_create_url
    assert_response :success
  end
end
