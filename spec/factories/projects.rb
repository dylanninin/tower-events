FactoryGirl.define do
  factory :project do
    name { Faker::Lorem.word }
    description { Faker::Lorem.paragraph }
    association :team
    association :creator, factory: :user
  end
end
