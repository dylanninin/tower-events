require 'rails_helper'

RSpec.describe Calendar, type: :model do
  before(:each) do
    User.current = create(:user)
  end

  it 'successfully' do
    create(:calendar)
  end
end
