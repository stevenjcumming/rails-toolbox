require 'httparty'

module ApiWrapper
  class Base

  include HTTParty
  base_uri 'https://api.example.com'
  headers 'Content-Type' => 'application/json'

  attr_reader :options

  def initialize
    api_token = Rails.application.credentials.api_wrapper.api_key
    @token = exchange_api_key_for_token(api_key)
    @headers = { 'Authorization' => "Bearer #{token}" }
  end

  def parse_response(response)
    if response.success?
      response.parsed_response
    else
      handle_error(response)
    end
  end

  def handle_error(response)
    # add error handling logic here
    raise "HTTP request failed: #{response.code}"
  end

  private

    def exchange_api_key_for_token(api_key)
      response = self.class.post('/auth', body: { api_key: api_key }.to_json)
      parse_response(response)['token']
    end
    
end