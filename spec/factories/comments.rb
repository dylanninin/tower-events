FactoryGirl.define do
  factory :comment do
    text { Faker::Lorem.sentence }
    association :commentable, factory: :todo
    association :team
    association :creator, factory: :user
  end
end
