module Api
  module V1
    class CreditsController < OrdersController
      def create
        credit = Credit.find_or_initialize_by(id: credit_parameter[:id])
        credit.assign_attributes(credit_parameter)
        credit.user = current_user
        credit.order_id = params[:order_id]
        begin
          credit.save!
          render :json => {credit: credit.reload}
        rescue
          errors = credit.errors.full_messages.join '. '
          render :json => {errors: errors}, :status => 400
        end
      end

      def credit_parameter
        params.require(:credit).permit(:id, :amount, :payer_type, :amount_type, :paying_org_id)
      end
    end
  end
end