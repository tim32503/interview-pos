# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'create new user' do
    it 'is valid' do
      user = FactoryBot.create(:user)

      expect(user).to be_valid
    end
  end
end
