require 'spec_helper'

feature 'Payments View' do
  include_context "the mini market"

  before do
    switch_to_subdomain(mini_market.subdomain)
  end

  context 'as a market manager' do
    before do
      sign_in_as(sally)
      visit '/admin/financials/payments'
    end

    it 'shows correct help message' do
      expect(page).to have_content('These are all completed payments made to you')
    end
  end

  context 'as a buyer' do
    before do
      sign_in_as(barry)
      visit '/admin/financials/payments'
    end

    it 'shows correct help message' do
      expect(page).to have_content('These are all completed payments you have made')
    end
  end

  context 'as a market manager' do
    before do
      sign_in_as(mary)
      visit '/admin/financials/payments'
    end

    it 'shows correct help message' do
      expect(page).to have_content('These are all completed payments to and from your organization')
    end
  end
end
