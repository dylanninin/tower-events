FactoryGirl.define do
  factory :todo do
    name "MyString"
    status 1
    due_to "2017-06-02"
    assignee nil
    todo_list nil
    project nil
    team nil
    creator nil
  end
end
