# spec/lib/api_wrapper/user_api_spec.rb
require 'rspec'
require 'webmock/rspec'
# require_relative 'user_api_wrapper' if not autoloaded

describe UserApiWrapper do
  let(:api_key) { 'your_api_key' }
  let(:bearer_token) { 'your_bearer_token' }
  let(:user_wrapper) { UserApiWrapper.new(api_key) }

  before do
    allow(user_wrapper).to receive(:exchange_api_key_for_token).and_return(bearer_token)
  end

  def stub_api_request(method, url, response_code, response_body)
    stub_request(method, url)
      .with(headers: { Authorization: "Bearer #{bearer_token}" } })
      .to_return(status: response_code, body: response_body, headers: {})
  end

  describe '#index' do
    context 'when the API request is successful' do
      before do
        stub_api_request(:get, 'https://api.example.com/users', 200, 'index_response')
      end

      it 'returns a successful response' do
        response = user_wrapper.index
        expect(response.code).to eq(200)
        expect(response.body).to eq('index_response')
      end
    end

    context 'when the API request fails' do
      before do
        stub_api_request(:get, 'https://api.example.com/users', 404, '')
      end

      it 'raises an exception' do
        expect { user_wrapper.index }.to raise_error(RuntimeError, 'HTTP request failed: 404')
      end
    end
  end

  describe '#show' do
    context 'when the API request is successful' do
      before do
        stub_api_request(:get, 'https://api.example.com/users/123', 200, 'show_response')
      end

      it 'returns a successful response' do
        response = user_wrapper.show(123)
        expect(response.code).to eq(200)
        expect(response.body).to eq('show_response')
      end
    end
  end

  describe '#create' do
    context 'when the API request is successful' do
      before do
        stub_api_request(:post, 'https://api.example.com/users', 201, 'create_response')
      end

      it 'returns a successful response' do
        data = { name: 'John Doe', email: 'john@example.com' }
        response = user_wrapper.create(data)
        expect(response.code).to eq(201)
        expect(response.body).to eq('create_response')
      end
    end
  end

  describe '#update' do
    context 'when the API request is successful' do
      before do
        stub_api_request(:put, 'https://api.example.com/users/123', 200, 'update_response')
      end

      it 'returns a successful response' do
        data = { name: 'Jane Doe' }
        response = user_wrapper.update(123, data)
        expect(response.code).to eq(200)
        expect(response.body).to eq('update_response')
      end
    end
  end

  describe '#destroy' do
    context 'when the API request is successful' do
      before do
        stub_api_request(:delete, 'https://api.example.com/users/123', 204, '')
      end

      it 'returns a successful response' do
        response = user_wrapper.destroy(123)
        expect(response.code).to eq(204)
        expect(response.body).to eq('')
      end
    end
  end
end
