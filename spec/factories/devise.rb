FactoryBot.define do
  factory :user do
    id {1}
    email {"test@user.com"}
    password {"qwerty"}
  end

  factory :admin do
    id {2}
    email {"test@admin.com"}
    password {"qwerty"}
    admin {true}
  end
end
