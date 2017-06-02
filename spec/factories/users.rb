FactoryGirl.define do
  factory :user do
    avatar { Faker::Avatar.image }
    sequence(:name) do |n|
      t = Faker::Internet.user_name(specifier: 10) + n.to_s * 10
      t[0, 15]
    end
    email { Faker::Internet.email }
    password 'secret'
    password_confirmation 'secret'
  end
end
