require 'rails_helper'

RSpec.describe Image, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:picture) }
  it { is_expected.to validate_presence_of(:page) }

  context 'when an image is choosen' do
    let(:image) { FactoryGirl.create(:image) }

    it 'is valid' do
      expect(image).to be_valid
    end

    it 'validates #picture size' do
      allow(image.picture).to receive_messages(:size => 7.megabytes)
      image.valid?
      expect(image.errors.messages[:picture]).to include("Maximale Bildgröße 5 MB")
    end

    it 'validates #total_upload_limit' do
      FactoryGirl.create(:image) # create a second image
      TOTAL_UPLOAD_LIMIT = stub_const('Image::TOTAL_UPLOAD_LIMIT', 2)

      image.valid?
      expect(image.errors.messages[:picture]).to include("Maximale Anzahl (#{TOTAL_UPLOAD_LIMIT}) an Bildern erreicht. Bitte lösche Bilder und versuche es erneut.")
    end
  end

  context "when no image is chosen" do
    let(:image) { FactoryGirl.build(:image, picture: nil) }

    it "returns an error message" do
      image.valid?
      expect(image).to be_invalid
      expect(image.errors.messages[:picture]).to include("can't be blank")
    end

    it 'is invalid' do
      expect(image).to be_invalid
    end
  end
end
