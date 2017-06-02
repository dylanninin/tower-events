FactoryGirl.define do
  factory :report do
    name { Faker::Lorem.word }
    content { Faker::Lorem.paragraph }
    association :team
    association :creator, factory: :user
  end
end
