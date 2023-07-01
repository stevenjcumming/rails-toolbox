# How you render errors may be different 
# Sub `id` for `reference_id` as needed
# Use this as template that can be updated with others contexts (or routes)
require 'rails_helper'

RSpec.describe Api::V1::ExamplesController, type: :request do
  # Create a user before running the tests
  before(:all) do
    @user = create(:user)
  end

  # Helper method to set valid headers
  let(:headers) { valid_headers(@user) }

  describe 'GET /api/v1/examples' do
    # Set up examples for the current user
    let!(:example1) { create(:example, user: @user) }
    let!(:example2) { create(:example, user: @user) }

    context 'when the request is valid' do
      before { get '/api/v1/examples', headers: headers }

      it { is_expected.to respond_with 200 }

      it 'returns the examples for the current user' do
        expect(json['examples'].size).to eq(2)
        expect(json['examples'][0]['id']).to eq(example1.id)
        expect(json['examples'][1]['id']).to eq(example2.id)
      end
    end

    context 'when the request is invalid' do
      before { get '/api/v1/examples', headers: {} }

      it { is_expected.to respond_with 401 }

      it 'returns an error message' do
        expect(errors).to have_unauthorized_error
      end
    end
  end

  describe 'GET /api/v1/examples/:id' do
    let(:example) { create(:example, user: @user) }
    let(:valid_id) { example.id }
    let(:invalid_id) { 999 }

    context 'when the example exists' do
      before { get "/api/v1/examples/#{valid_id}", headers: headers }

      it { is_expected.to respond_with 200 }

      it 'returns the example' do
        expect(json['id']).to eq(example.id)
      end
    end

    context 'when the example does not exist' do
      before { get "/api/v1/examples/#{invalid_id}", headers: headers }

      it { is_expected.to respond_with 401 }

      # For security reasons even if record is not found return unauthorized
      it 'returns an error message' do
        expect(errors).to have_unauthorized_error
      end
    end
  end

  describe 'POST /api/v1/examples' do
    let(:valid_params) { { param_1: 'value1', param_2: 'value2', param_3: 'value3' } }
    let(:invalid_params) { { param_1: '', param_2: 'value2', param_3: 'value3' } }

    context 'when the request is valid' do
      before { post '/api/v1/examples', params: valid_params, headers: headers }

      it { is_expected.to respond_with 200 }

      it 'creates a new example' do
        expect(Example.count).to eq(1)
      end

      it 'returns the created example' do
        expect(json['param_1']).to eq('value1')
        expect(json['param_2']).to eq('value2')
        expect(json['param_3']).to eq('value3')
      end
    end

    context 'when the request is invalid' do
      before { post '/api/v1/examples', params: invalid_params, headers: headers }

      it { is_expected.to respond_with 400 }

      it 'returns an error' do
        expect(errors).to have_validation_error
      end
    end
  end

  describe 'PATCH /api/v1/examples/:id' do
    let!(:example) { create(:example, user: @user) }
    let(:valid_params) { { param_1: 'new value' } }
    let(:invalid_params) { { param_1: '' } }

    context 'when the example exists' do
      context 'and the request is valid' do
        before { patch "/api/v1/examples/#{example.id}", params: valid_params, headers: headers }

        it { is_expected.to respond_with 200 }

        it 'returns the updated example' do
          expect(json['param_1']).to eq('new value')
        end
      end

      context 'and the request is invalid' do
        before { patch "/api/v1/examples/#{example.id}", params: invalid_params, headers: headers }

        it { is_expected.to respond_with 400 }

        it 'returns an error message' do
          expect(errors).to have_validation_error
        end
      end
    end

    context 'when the example does not exist' do
      before { patch "/api/v1/examples/999", params: valid_params, headers: headers }

      it { is_expected.to respond_with 401 }

      it 'returns an error message' do
        expect(errors).to have_unauthorized_error
      end
    end
  end

  describe 'DELETE /api/v1/examples/:id' do
    let!(:example) { create(:example, user: @user) }

    context 'when the example exists' do
      before { delete "/api/v1/examples/#{example.id}", headers: headers }

      it { is_expected.to respond_with 200 }

      it 'deletes the example' do
        expect(Example.count).to eq(0)
      end
    end

    context 'when the example does not exist' do
      before { delete "/api/v1/examples/999", headers: headers }

      it { is_expected.to respond_with 401 }

      it 'returns an error message' do
        expect(errors).to have_unauthorized_error
      end
    end
  end
end
