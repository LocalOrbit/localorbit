require 'spec_helper'

describe User do
  describe 'roles' do
    it 'admin? returns true if role is "admin"' do
      user = FactoryGirl.build(:user)
      user.role = 'admin'
      expect(user.admin?).to be_true
    end

    it 'admin? returns false if role is not "admin"' do
      user = FactoryGirl.build(:user)
      user.role = 'user'
      expect(user.admin?).to be_false

      user.role = 'manager'
      expect(user.admin?).to be_false

      user.role = 'something else'
      expect(user.admin?).to be_false
    end
  end
end
