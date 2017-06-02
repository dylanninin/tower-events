require 'rails_helper'

RSpec.describe Dummy, type: :model do
  it 'create successfully' do
    create_list(:dummy, rand(1...5))
  end
end
