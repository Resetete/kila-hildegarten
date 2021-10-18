require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  describe "POST #create" do
    context "with valid attributes" do
      it "create new image" do
        p FactoryGirl.build(:image)
        params = FactoryGirl.attributes_for(:image)
        post :create, params: { image: params }

        expect(Image.count).to eq(1)
      end
    end
  end
end
