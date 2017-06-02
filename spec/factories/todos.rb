FactoryGirl.define do
  factory :todo do
    name { Faker::Lorem.word }
    content { Faker::Lorem.paragraph }
    due_to { rand(1..5).days.from_now }
    association :assignee, factory: :user
    association :todo_list
    association :project
    association :team
    association :creator, factory: :user
  end
end
