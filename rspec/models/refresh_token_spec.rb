# https://github.com/thoughtbot/shoulda-matchers
RSpec.describe RefreshToken, type: :model do

  describe "validations" do 
    subject { build(:refresh_token) }
    it { is_expected.to validate_presence_of(:expired_at) }
    it { is_expected.to allow_value(nil).for(:revoked_at) }
    it { is_expected.to validate_datetime_of(:revoked_at).only_future.allow_nil }
    it { is_expected.to validate_datetime_of(:expired_at).only_future }
  end

  describe "associations" do 
    it { is_expected.to belong_to(:user) }
  end

  describe 'callbacks' do
    it { is_expected.to callback(:set_encrypted_token).before(:validation).on(:create) }
    it { is_expected.to callback(:set_expired_at).before(:validation).on(:create) }
  end

  describe "#revoked?" do
    context "when revoked_at is not nil" do
      let(:refresh_token) { build(:refresh_token, :revoked) }
      it 'returns true' do
        expect(refresh_token).to be_revoked
      end
    end

    context "when revoked_at is nil" do
      it { is_expected.not_to be_revoked }
    end
  end

  describe "#expired?" do
    context "when expired_at is in the past" do
      let(:refresh_token) { build(:refresh_token, :expired) }
      it 'returns true' do
        expect(refresh_token).to be_expired
      end
    end

    context "when expired_at is in the future" do 
      it { is_expected.not_to be_expired }
    end
  end

  describe "#valid_token?" do
    context "when the token is not revoked and not expired" do
      it { is_expected.to be_valid_token }
    end

    context "when revoked_at is not nil" do 
      let(:refresh_token) { build(:refresh_token, :revoked) }
      it 'returns false' do
        expect(refresh_token).not_to be_valid_token
      end
    end

    context "when expired_at is in the past" do 
      let(:refresh_token) { build(:refresh_token, :expired) }
      it 'returns false' do
        expect(refresh_token).not_to be_valid_token
      end
    end
  end

  describe ".find_by_token" do
    context "when token is valid" do
      let(:refresh_token) { create(:refresh_token, token: 'sample_token') }
      it "returns a refresh_token" do
        result = RefreshToken.find_by_token('sample_token')
        expect(result).to eq(refresh_token)
      end
    end

    context "when token is invalid" do
      let(:refresh_token) { create(:refresh_token, token: 'sample_token') }
      it "returns nil" do
        result = RefreshToken.find_by_token("fake_token")
        expect(result).to eq(nil)
      end
    end
  end
end
