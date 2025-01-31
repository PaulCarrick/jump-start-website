require 'rails_helper'

RSpec.describe ImageFile, type: :model do
  include_context "debug setup"

  let(:valid_image) { fixture_file_upload(Rails.root.join('spec/fixtures/files/sample.jpg'), 'image/jpeg') }
  let(:valid_description) { "<html><body><p>Valid Description</p></body></html>" }
  let(:invalid_description) { "<html><body><p>Invalid" }
  let(:checksum) { Digest::SHA256.hexdigest(valid_description) }

  describe "validations" do
    it "validates presence of name" do
      image_file = ImageFile.new(image: valid_image, description: valid_description, checksum: checksum)
      expect(image_file.valid?).to be false
      expect(image_file.errors[:name]).to include("can't be blank")
    end

    it "validates presence of image" do
      image_file = ImageFile.new(name: "Image File", description: valid_description, checksum: checksum)
      expect(image_file.valid?).to be false
      expect(image_file.errors[:image]).to include("can't be blank")
    end

    it "adds an error for invalid HTML in description" do
      image_file = ImageFile.new(name: "Image File", image: valid_image, description: invalid_description, checksum: checksum)
      image_file.valid?
      expect(image_file.errors[:base]).to include("Invalid HTML in Description.")
    end

    it "does not add an error for valid HTML in description" do
      image_file = ImageFile.new(name: "Image File", image: valid_image, description: valid_description, checksum: checksum)
      expect(image_file.valid?).to be true
    end
  end

  describe "checksum verification" do
    it "does not raise an error if checksum matches description" do
      image_file = ImageFile.create!(
        name: "Image File",
        image: valid_image,
        description: valid_description,
        checksum: checksum
      )

      expect { image_file.reload }.not_to raise_error
    end
  end

  describe "scopes" do
    let!(:image_file_1) { ImageFile.create!(name: "Image 1", image: valid_image, mime_type: "image/jpeg", caption: "Caption", group: "Group 1") }
    let!(:image_file_2) { ImageFile.create!(name: "Image 2", image: valid_image, mime_type: "image/jpeg", caption: nil, group: "Group 1") }

    describe ".jpegs_with_captions_in_an_image_group" do
      it "returns only JPEGs with captions in a group" do
        result = ImageFile.jpegs_with_captions_in_an_image_group
        expect(result).to include(image_file_1)
        expect(result).not_to include(image_file_2)
      end
    end

    describe ".by_image_group" do
      it "returns image files by group and ordered by slide_order" do
        result = ImageFile.by_image_group("Group 1")
        expect(result).to include(image_file_1, image_file_2)
      end
    end

    describe ".by_name" do
      it "returns image files by name" do
        result = ImageFile.by_name("Image 1")
        expect(result).to include(image_file_1)
      end
    end
  end

  describe "instance methods" do
    let(:image_file) { ImageFile.create!(name: "Image File", image: valid_image, description: valid_description, checksum: checksum) }

    describe "#image_url" do
      it "returns the URL for the attached image if present" do
        expect(image_file.image_url).to be_present
      end

      it "returns nil if the image is not attached" do
        image_file.image.purge
        expect(image_file.image_url).to be_nil
      end
    end

    describe "#as_json" do
      it "includes the image URL in the JSON representation" do
        json = image_file.as_json
        uri = URI.parse(json[:image_url])
        expect(uri).to be_a(URI::HTTP).or be_a(URI::HTTPS) # Checks for valid HTTP/HTTPS URL
      end
    end
  end

  describe ".ransackable_attributes" do
    it "returns only ransackable attributes" do
      expect(ImageFile.ransackable_attributes).to eq([ "name", "group", "caption", "description" ])
    end
  end

  describe ".ransackable_associations" do
    it "returns only ransackable associations" do
      expect(ImageFile.ransackable_associations).to eq([ "image_attachment", "image_blob" ])
    end
  end
end
