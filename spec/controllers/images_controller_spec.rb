require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  let!(:admin) { FactoryGirl.create(:admin) }

  describe "POST #create" do
    context "as admin with valid attributes" do
      it "create new image" do
        sign_in(admin)

        allow_any_instance_of(PictureUploader).to receive(:store!)

        params = FactoryGirl.attributes_for(:image)
        expect { post :create, params: { image: params } }.to change { Image.all.count }.by(1)
      end
    end

    context "with invalid attributes" do
      it "does not create a new image" do
        sign_in(admin)

        params = FactoryGirl.attributes_for(:image, :invalid_image)
        post :create, params: { image: params }

        #expect { post :create, params: { image: params } }.to change { Image.all.count }.by(0)
        expect(response).to render_template('new')

        #expect(response).to redirect_to(new_image_path)
        expect(response).to have_http_status(200)
        expect(Image.all.count).to eq(0)
      end

      it 're-renders the new form'
    end
  end

  describe "DELETE #destroy" do
    let!(:image) { FactoryGirl.create(:image) }
    let(:params) { {id: image.id } }

    it 'as admin deletes image' do
      allow_any_instance_of(PictureUploader).to receive(:download!)
      sign_in(admin)
      expect { delete :destroy, params: { id: image.id } }.to change { Image.all.count }.by(-1)
    end

    it 'as guest does not delete image' do
      sign_out(admin)
      expect { delete :destroy, params: { id: image.id } }.to change { Image.all.count }.by(0)
    end
  end
end
