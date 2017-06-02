FactoryGirl.define do
  factory :team do
    name { Faker::Team.name }
    description { Faker::Lorem.paragraph }
    association :creator, factory: :user
  end
end
