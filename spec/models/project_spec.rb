require 'rails_helper'

RSpec.describe Project, type: :model do
  before(:each) do
    User.current = create(:user)
  end

  it 'successfully' do
    create(:project)
  end
end
