require "googleauth"

module Services
  class CloudFunctionService
    CLOUD_FUNCTION_URL = 'https://us-central1-third-octagon-429617-s2.cloudfunctions.net/scrap-xepelin'.freeze

    class << self
      def api_request(category)
        access_token = fetch_access_token
        service_account_email = 'agustinescobar.a001@gmail.com'
        target_audience = CLOUD_FUNCTION_URL
        identity_token = fetch_identity_token(service_account_email, target_audience, access_token)
        uri = "#{CLOUD_FUNCTION_URL}?category=#{category}"
        
        headers = {
          'Authorization' => "Bearer #{identity_token}",
          'Content-Type' => 'application/json'
        }
    
        result = RestClient.send(:get, uri, headers)
        JSON.parse(result.body.with_indifferent_access)
      end

      private

      def fetch_access_token
        decoded_json_key = Base64.decode64(Rails.application.credentials[:gcp_cloud_functions_secret])
        json_key_io = StringIO.new(decoded_json_key)
        authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: json_key_io,
          scope: 'https://www.googleapis.com/auth/cloud-platform'
        )

        authorizer.fetch_access_token!['access_token']
      end

      def fetch_identity_token(service_account_email, target_audience, access_token)
        url = "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/#{service_account_email}:generateIdToken"
        body = {
          audience: target_audience,
          includeEmail: true
        }.to_json
        response = RestClient.post(
          url,
          body: body,
          headers: {
            'Content-Type' => 'application/json',
            'Authorization' => "Bearer #{access_token}"
          }
        )
        if response.code == 200
          JSON.parse(response.body)['token']
        else
          raise "Failed to fetch identity token: #{response.body}"
        end
      end
    end
  end
end