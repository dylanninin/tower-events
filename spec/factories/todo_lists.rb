FactoryGirl.define do
  factory :todo_list do
    name { Faker::Lorem.word }
    association :project
    association :team
    association :creator, factory: :user
  end
end
