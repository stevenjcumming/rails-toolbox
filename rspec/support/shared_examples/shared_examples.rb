# spec/support/shared_examples/referenceable_shared_example.rb
require "rails_helper"

RSpec.shared_examples "referenceable" do
  describe "validations" do
    it "expect to set :reference_id before validation" do
      described_subject = described_class.new
      described_subject.valid?
      expect(described_subject.reference_id).to be_present
    end
  end
end
