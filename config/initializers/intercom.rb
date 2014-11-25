IntercomRails.config do |config|
  # == Intercom app_id

  if Figaro.env.deploy_env == 'production'
    # config.app_id = ["INTERCOM_APP_ID"] || "oh52vbpl"
    config.app_id = "oh52vbpl"
    config.api_secret = "mFWk_GyKfsZmhnekr3r0uky-pjjPLAgKIkut4yNN"
    config.api_key = "fe0ac32a401cdef0784140fa0610ed906969ba4d"
  else
    # Test mode:
    config.app_id =  "bn6bws5t"
    config.api_key = "c3eb5968384cb5f2afef55634023b9b201a00985"
  end

  # == Intercom secret key
  # This is required to enable secure mode, you can find it on your Intercom
  # "security" configuration page.
  #

  # == Intercom API Key
  # This is required for some Intercom rake tasks like importing your users;
  # you can generate one at https://app.intercom.io/apps/api_keys.
  #

  # == Enabled Environments
  # Which environments is auto inclusion of the Javascript enabled for
  #
  config.enabled_environments = ["development", "production"]

  # == Current user method/variable
  # The method/variable that contains the logged in user in your controllers.
  # If it is `current_user` or `@user`, then you can ignore this
  #
  # config.user.current = Proc.new { current_user }

  # == User model class
  # The class which defines your user model
  #
  # config.user.model = Proc.new { User }

  # == Exclude users
  # A Proc that given a user returns true if the user should be excluded
  # from imports and Javascript inclusion, false otherwise.
  #
  # config.user.exclude_if = Proc.new { |user| user.deleted? }

  # == User Custom Data
  # A hash of additional data you wish to send about your users.
  # You can provide either a method name which will be sent to the current
  # user object, or a Proc which will be passed the current user.
  #
  # config.user.custom_data = {
  #   :plan => Proc.new { |current_user| current_user.plan.name },
  #   :favorite_color => :favorite_color
  # }

  config.user.custom_data = {
    :role => Proc.new { |user|
      case
        when user.admin?
          "Admin"
        when user.market_manager?
          "Market Manager"
        when user.seller?
          "Seller"
        else
          "Buyer"
        end
    }
  }

  # == User -> Company association
  # A Proc that given a user returns an array of companies
  # that the user belongs to.
  #
  # config.user.company_association = Proc.new { |user| user.companies.to_a }
  # config.user.company_association = Proc.new { |user| [user.company] }

  # == Current company method/variable
  # The method/variable that contains the current company for the current user,
  # in your controllers. 'Companies' are generic groupings of users, so this
  # could be a company, app or group.
  #
  # config.company.current = Proc.new { current_company }

  # == Company Custom Data
  # A hash of additional data you wish to send about a company.
  # This works the same as User custom data above.
  #
  # config.company.custom_data = {
  #   :number_of_messages => Proc.new { |app| app.messages.count },
  #   :is_interesting => :is_interesting?
  # }

  # == Company Plan name
  # This is the name of the plan a company is currently paying (or not paying) for.
  # e.g. Messaging, Free, Pro, etc.
  #
  # config.company.plan = Proc.new { |current_company| current_company.plan.name }

  # == Company Monthly Spend
  # This is the amount the company spends each month on your app. If your company
  # has a plan, it will set the 'total value' of that plan appropriately.
  #
  # config.company.monthly_spend = Proc.new { |current_company| current_company.plan.price }
  # config.company.monthly_spend = Proc.new { |current_company| (current_company.plan.price - current_company.subscription.discount) }

  # == Inbox Style
  # This enables the Intercom inbox which allows your users to read their
  # past conversations with your app, as well as start new ones. It is
  # disabled by default.
  #   * :default shows a small tab with a question mark icon on it
  #   * :custom attaches the inbox open event to an anchor with an
  #             id of #Intercom.
  #
  # config.inbox.style = :default
  # config.inbox.style = :custom
end

# intercom-ruby gem
Intercom.app_id = IntercomRails.config.app_id
Intercom.app_api_key = IntercomRails.config.api_key



