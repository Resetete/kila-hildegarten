require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  describe "POST #create" do
    context "with valid attributes" do
      it "create new image" do
        FactoryGirl.create(:image)
        params = FactoryGirl.attributes_for(:image)
        post :create, params: { image: params }
        expect(Image.count).to eq(1)
      end
    end

    context "with invalid attributes" do
      it "does not create a new image" do
        post :create, params: { image: FactoryGirl.attributes_for(:image, :invalid_image) }
        expect(Image.count).to eq(0)
      end
    end
  end
end
