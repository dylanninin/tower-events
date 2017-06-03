require 'rails_helper'

RSpec.describe TodoList, type: :model do
  before(:each) do
    User.current = create(:user)
  end

  it 'successfully' do
    create(:todo_list)
  end
end
