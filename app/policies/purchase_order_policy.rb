class PurchaseOrderPolicy < ApplicationPolicy

  # def create?
    # binding.pry

    # KXM GC: policy PurchaseOrder#create? checking current_market didn't work.  Other ideas?
    # current_market.present? && current_market.is_consignment_market?

    # I played with setting a custom user context (defined below) that includes the market, but that nests the current user as an instance variable (along with current_market) of the pundit user, making all calls to 'user' have to be 'user.user'.  Ugly.  Tried assigning user to UserContext self, but that threw an error (as expected, really)

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