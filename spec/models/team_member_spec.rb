require 'rails_helper'

RSpec.describe TeamMember, type: :model do
  before(:each) do
    User.current = create(:user)
  end

  it 'successfully' do
    create(:team_member)
  end
end
