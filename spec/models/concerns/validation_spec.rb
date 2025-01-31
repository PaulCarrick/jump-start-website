require 'rails_helper'

RSpec.describe Validation, type: :module do
  include_context "debug setup"

  class DummyModel
    include ActiveModel::Model
    include ActiveModel::Validations
    include Validation

    attr_accessor :html_content, :field_name, :checksum, :data

    def generate_checksum(data)
      Digest::SHA256.hexdigest(data)
    end
  end

  let(:dummy) { DummyModel.new(html_content: "<html><body>Valid HTML</body></html>", field_name: :html_content) }

  describe "#validate_html" do
    context "when the HTML is valid" do
      it "returns true and does not add errors" do
        valid_html = "<html><body><p>Valid HTML</p></body></html>"
        result = dummy.send(:validate_html, valid_html, :html_content)

        expect(result).to be true
        expect(dummy.errors[:html_content]).to be_empty
      end
    end

    context "when the HTML is invalid" do
      it "returns false and adds an error message" do
        invalid_html = "<html><body><p>Invalid HTML"
        result = dummy.send(:validate_html, invalid_html, :html_content)

        expect(result).to be false
        expect(dummy.errors[:html_content]).not_to be_empty
      end
    end

    context "when the HTML is nil" do
      it "returns true and does not add errors" do
        result = dummy.send(:validate_html, nil, :html_content)

        expect(result).to be true
        expect(dummy.errors[:html_content]).to be_empty
      end
    end
  end

  describe "#validate_checksum" do
    context "when the data is present and the checksum matches" do
      it "returns true" do
        data = "Sample data"
        checksum = dummy.generate_checksum(data)
        result = dummy.send(:validate_checksum, checksum, data)

        expect(result).to be true
      end
    end

    context "when the data is present and the checksum does not match" do
      it "returns false" do
        data = "Sample data"
        checksum = "incorrect_checksum"
        result = dummy.send(:validate_checksum, checksum, data)

        expect(result).to be false
      end
    end

    context "when the data is nil" do
      it "returns true" do
        result = dummy.send(:validate_checksum, "checksum", nil)

        expect(result).to be true
      end
    end

    context "when the data is empty" do
      it "returns true" do
        result = dummy.send(:validate_checksum, "checksum", "")

        expect(result).to be true
      end
    end
  end
end
