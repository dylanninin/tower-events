FactoryGirl.define do
  factory :calendar_event do
    name { Faker::Lorem.word }
    start_date { rand(1..5).days.from_now }
    end_date { start_date + rand(1...5) }
    association :calendarable, factory: :calendar
    association :team
    association :creator, factory: :user
  end
end
