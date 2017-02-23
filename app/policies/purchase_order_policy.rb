class PurchaseOrderPolicy < ApplicationPolicy
# This policy implementation deprecated for now.  Leverage current_market.present? && current_market.is_consignment_market?

  # def create?

    # Not feasible for the intended purpose as Pundit (out of the box) only allows reference to the current_user.

    # I played with setting a custom user context (defined below) that includes the market, but that nests the current user as an instance variable (along with current_market) of the Pundit user, making all calls to 'user' have to be 'user.user'.  Ugly.  Tried assigning user to UserContext self, but that threw an error (as expected, really)

    # Defined somewhere:
    # -------------------
    # class UserContext
    #   attr_reader :user, :current_market

    #   def initialize(user, current_market)
    #     @user = user
    #     @current_market   = current_market
    #   end
    # end


    # Defined in the Application controller:
    # ---------------------------------------
    # def pundit_user
    #   UserContext.new(current_user, request.ip)
    # end

  #   true
  # end

end