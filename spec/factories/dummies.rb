FactoryGirl.define do
  factory :dummy do
    title { Faker::Pokemon.name }
    description { Faker::Lorem.paragraph[0...rand(1...100)] }
    icon { Faker::Avatar.image }
  end
end
