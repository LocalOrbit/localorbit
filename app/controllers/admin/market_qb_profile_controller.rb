class Admin::MarketQbProfileController < AdminController
  before_action :require_admin_or_market_manager
  before_action :find_market
  before_action :load_qb_session

  def index
  end

  def show
  end

  def update
    @market.organization.qb_profile.session = session

    if @market.organization.qb_profile.update_attributes(qb_params)
      redirect_to [:admin, @market, :qb_profile], notice: 'QuickBooks accounts updated successfully'
    else
      flash.now.alert = "Could not update QuickBooks profile"
      render :show
    end
  end

  def authenticate
    callback = oauth_callback_admin_market_qb_profile_url
    token = QB_OAUTH_CONSUMER.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = Marshal.dump(token)
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end

  def oauth_callback
    at = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
    session[:qb_token] = at.token
    session[:qb_secret] = at.secret
    session[:qb_realm_id] = params['realmId']
    # store the token, secret & RealmID somewhere for this user, you will need all 3 to work with Quickbooks-Ruby

    # Create token entry
    if !session[:qb_id].nil?
      qb_token = QbToken.find(session[:qb_id])
    else
      qb_token = QbToken.new
    end
    qb_token.organization_id = current_market.organization.id
    qb_token.access_token = at.token
    qb_token.access_secret = at.secret
    qb_token.realm_id = params['realmId']
    qb_token.token_expires_at = 180.days.from_now
    session[:qb_id] = qb_token.save

    # Create profile entry
    qb_profile = QbProfile.find_by_organization_id(current_market.organization.id)
    if qb_profile.nil?
      qb_profile = QbProfile.new
      qb_profile.organization_id = current_market.organization.id
      qb_profile.save
    end

    render :oauth_callback , notice: "Your QuickBooks account has been successfully linked."
  end

  def disconnect
    qb_token = QbToken.find(session[:qb_id])
    qb_token.delete
    session.delete(:qb_id)
    session.delete(:qb_token)
    session.delete(:qb_secret)
    session.delete(:qb_realm_id)

    redirect_to admin_market_qb_profile_path

  end

  def sync
    # TODO: Disable button during use, add status indicator? Separate buttons for each?

    @qb_profile = @market.organization.qb_profile
    customers = current_user.
                  managed_organizations.
                  where(org_type: Organization::TYPE_BUYER,
                        qb_org_id: nil)
    puts customers.length
    customers.each do |cust|
      retry_cnt = 0
      loop do
        begin
          result = Quickbooks::Customer.create_customer(cust, session)
          cust.qb_org_id = result.id
          cust.save!(validate: false)
          failed = false
        rescue => e
          puts e
          failed = true
          retry_cnt = retry_cnt + 1
        end
        break if !failed || retry_cnt > 10
        end
      end

    vendors = current_user.
                managed_organizations.
                where(org_type: Organization::TYPE_SUPPLIER,
                      qb_org_id: nil)
    puts customers.length
    vendors.each do |vend|
      retry_cnt = 0
      loop do
        begin
          result = Quickbooks::Vendor.create_vendor(vend, session)
          vend.qb_org_id = result.id
          vend.save!(validate: false)
          failed = false
        rescue => e
          puts e
          failed = true
          retry_cnt = retry_cnt + 1
        end
        break if !failed || retry_cnt > 10
      end
    end

    items = current_user.managed_products.where(qb_item_id: nil)
    items.each do |item|
      retry_cnt = 0
      loop do
        begin
          result = Quickbooks::Item.create_item(item, session, @qb_profile)
          if !result.nil?
            item.qb_item_id = result.id
            item.skip_validation = true
            item.save!(validate: false)
            failed = false
          else
            puts item.name
          end
        rescue => e
          puts e
          failed = true
          retry_cnt = retry_cnt + 1
        end
        break if !failed || retry_cnt > 10
      end
    end

    redirect_to admin_market_qb_profile_path

  end

  private

  def qb_params
    params.require(:qb_profile).permit(
        :income_account_name,
        :expense_account_name,
        :asset_account_name,
        :ar_account_name,
        :ap_account_name,
        :fee_income_account_name,
        :delivery_fee_account_name,
        :delivery_fee_item_name,
        :consolidated_supplier_item_name,
        :consolidated_buyer_item_name,
        :prefix)
  end
end
