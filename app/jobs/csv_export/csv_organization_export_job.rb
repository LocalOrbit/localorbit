module CSVExport
  class CSVOrganizationExportJob < Struct.new(:user, :ids) # pass in the datafile like is done right now in uploadcontroller, i.e.

    def enqueue(job)
    end

    def success(job)
    end

    def error(job, exception)
      puts exception
    end

    def failure(job)
    end

    def perform
      organizations = Organization.where(id: ids).order(:name)
      csv = CSV.generate do |f|
        f << ["Name", "Market", "Registered On", "Role", "Type", "Shipping Address", "Shipping Phone", "Billing Address", "Billing Phone", "Users", "User Emails"]

        def full_address(address)
          if address.present?
            [
                address.address.strip,
                address.city,
                address.state,
                address.zip
            ].join(", ")
          end
        end

        def users_list(org)
          org.users.map{|u| u.name.nil? ? "No name entered" : u.name }.join(", ")
        end

        def users_emails(org)
          org.users.map{|u| u.email.nil? ? "None" : u.email}.join(", ")
        end

        def buyer_type(org)
          org.can_sell? || org.buyer_org_type.nil? ? "" : org.buyer_org_type
        end

        organizations.each do |organization|
          f << [
              organization.name,
              organization.markets.first.name,
              organization.created_at.strftime("%d-%B-%y"),
              (organization.can_sell? ? "Supplier" : "Buyer"),
              buyer_type(organization),
              full_address(organization.shipping_location),
              organization.shipping_location.try(:phone),
              full_address(organization.billing_location),
              organization.billing_location.try(:phone),
              users_list(organization),
              users_emails(organization)
          ]
        end
      end

      # Send via email
      ExportMailer.delay(priority: 30).export_success(user.email, 'organization', csv)
    end

  end
end