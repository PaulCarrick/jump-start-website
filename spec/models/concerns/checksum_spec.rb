require 'rails_helper'

RSpec.describe Checksum, type: :module do
  include_context "debug setup"

  let(:section) { create(:section) }
  let(:image_file) { create(:image_file) }
  let(:other_model) { create(:page) }

  describe "populate_checksum" do
    context "when the model is a Section or ImageFile" do
      before do
        allow(section).to receive(:kind_of?).with(Section).and_return(true)
        allow(section).to receive(:kind_of?).with(ImageFile).and_return(false)

        allow(image_file).to receive(:kind_of?).with(Section).and_return(false)
        allow(image_file).to receive(:kind_of?).with(ImageFile).and_return(true)
      end

      it "sets checksum based on description if present" do
        section.description = "Test description"
        section.send(:populate_checksum) # Manually trigger the callback

        expect(section.checksum).to eq(section.send(:generate_checksum, section.description))
      end

      it "does not set checksum if description is blank" do
        section = create(:section, description: nil)

        expect(section.checksum).to be_nil
      end
    end

    context "when the model is neither a Section nor ImageFile" do
      before do
        allow(other_model).to receive(:kind_of?).with(Section).and_return(false)
        allow(other_model).to receive(:kind_of?).with(ImageFile).and_return(false)
      end
    end
  end

  describe "generate_checksum" do
    let(:data) { "Test data" }

    it "produces different checksums for different inputs" do
      checksum1 = section.send(:generate_checksum, "Input 1")
      checksum2 = section.send(:generate_checksum, "Input 2")

      expect(checksum1).not_to eq(checksum2)
    end
  end
end
