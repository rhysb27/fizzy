require "test_helper"

class My::PasskeyChallengesControllerTest < ActionDispatch::IntegrationTest
  test "returns a fresh challenge" do
    untenanted do
      post my_passkey_challenge_url

      assert_response :success
      assert_not_nil response.parsed_body["challenge"]
    end
  end

  test "returns a different challenge each time" do
    untenanted do
      post my_passkey_challenge_url
      first_challenge = response.parsed_body["challenge"]

      post my_passkey_challenge_url
      second_challenge = response.parsed_body["challenge"]

      assert_not_equal first_challenge, second_challenge
    end
  end
end
