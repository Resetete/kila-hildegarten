include ActionDispatch::TestProcess::FixtureFile

FactoryGirl.define do
  factory :image do
    name { Faker::Name.name }
    picture { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/testfiles/kris1.jpg')) }
    page { 'Home' }
  end
end
