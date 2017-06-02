FactoryGirl.define do
  factory :calendar_event do
    name "MyString"
    start_date "2017-06-02"
    end_date "2017-06-02"
    calendarable nil
    team nil
    creator nil
  end
end
