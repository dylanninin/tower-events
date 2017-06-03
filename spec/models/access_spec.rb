require 'rails_helper'

RSpec.describe Access, type: :model do
  before(:each) do
    User.current = create(:user)
  end

  it 'successfully' do
    create(:access)
  end
end
