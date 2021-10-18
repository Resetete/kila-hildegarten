require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  describe "POST #create" do
    context "with valid attributes" do
      before { Image.all.destroy_all }
      it "create new image" do
        FactoryGirl.create(:image)
        params = FactoryGirl.attributes_for(:image)
        post :create, params: { image: params }
        expect(Image.count).to eq(1)
      end
    end
  end
end
