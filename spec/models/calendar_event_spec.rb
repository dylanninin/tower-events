require 'rails_helper'

RSpec.describe CalendarEvent, type: :model do
  before(:each) do
    User.current = create(:user)
  end

  it 'successfully' do
    create(:calendar_event)
  end
end
