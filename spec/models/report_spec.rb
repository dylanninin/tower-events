require 'rails_helper'

RSpec.describe Report, type: :model do
  before(:each) do
    User.current = create(:user)
  end

  it 'successfully' do
    create(:report)
  end
end
