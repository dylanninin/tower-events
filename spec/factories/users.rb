FactoryGirl.define do
  factory :user do
    avatar { Faker::Avatar.image }
    sequence(:name) { Faker::Internet.user_name(specifier: 10) }
    email { Faker::Internet.email }
    password 'secret'
    password_confirmation 'secret'
  end
end
