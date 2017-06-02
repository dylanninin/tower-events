FactoryGirl.define do
  factory :team_member do
    association :team
    association :member, factory: :user
    role "role"
    association :creator, factory: :user
  end
end
