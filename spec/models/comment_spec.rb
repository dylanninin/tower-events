require 'rails_helper'

RSpec.describe Comment, type: :model do
  before(:each) do
    User.current = create(:user)
  end

  it 'successfully' do
    create(:comment)
  end
end
