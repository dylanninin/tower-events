FactoryGirl.define do
  factory :comment do
    text "MyString"
    commentable nil
    team nil
    creator nil
  end
end
