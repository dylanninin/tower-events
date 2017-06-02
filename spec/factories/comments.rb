FactoryGirl.define do
  factory :comment do
    replied_to_id nil
    text { Faker::Lorem.sentence }
    association :commentable, factory: :todo
    association :team
    association :creator, factory: :user
  end
end
