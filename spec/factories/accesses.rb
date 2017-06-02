FactoryGirl.define do
  factory :access do
    association :user
    role "role"
    association :accessable, factory: :project
    association :team
    association :creator, factory: :user
  end
end
