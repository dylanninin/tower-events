require 'rails_helper'

RSpec.describe Team, type: :model do
  before(:each) do
    User.current = create(:user)
  end

  it 'successfully' do
    create(:team)
  end
end
