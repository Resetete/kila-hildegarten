require 'rails_helper'

RSpec.describe Image, type: :model do
  #subject { described_class.new(page: page, picture: picture, name: name) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:picture) }
  it { is_expected.to validate_presence_of(:page) }

  context 'when an image is choosen' do
    let(:image) { FactoryGirl.create(:image) }
    it 'is valid' do
      #image = FactoryGirl.create(:image)
      expect(image).to be_valid
    end

    it 'validates #picture size' do
      p image.picture.size
    end

    it 'validates #total_upload_limit'
  end

  context "when no image is chosen" do
    it "returns an error message" do
      image = FactoryGirl.build(:image, picture: nil)
      expect(image).to be_invalid
      expect(image.errors.messages[:picture]).to eq ["can't be blank"]
    end
  end
end
