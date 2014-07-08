module Devise
  module Strategies
    class TokenAuth < Authenticatable
      def valid?
        params[:auth_token].present? && mapping.to.respond_to?(:for_auth_token)
      end

      def authenticate!
        # if the authentication header is an acceptible value
        if (resource = mapping.to.for_auth_token(params[:auth_token]))
          env["devise.skip_storage"] = true
          success!(resource, "success")
        else
          fail(:not_found_in_database)
        end
      end
    end
  end
end
