include ActionDispatch::TestProcess::FixtureFile

FactoryGirl.define do
  factory :image do
    name { Faker::Name.name }
    #picture { fixture_file_upload(Rails.root.join(*%w[spec fixtures testfiles kris1.jpg]), 'image/jpg') }
    picture { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/testfiles/kris1.jpg')) }
    page { 'Home' }
  end
end
