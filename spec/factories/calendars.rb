FactoryGirl.define do
  factory :calendar do
    name { Faker::Lorem.word }
    color { Faker::Color.hex_color }
    association :team
    association :creator, factory: :user
  end
end
