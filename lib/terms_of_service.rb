module TermsOfService
	def self.url
		"http://localorbit.com/local-orbit-terms-of-service/"
	end

	def self.accept(user:,time:, ip_addr:)
		user.update_attributes(accepted_terms_of_service_at:time,accepted_terms_of_service_from:ip_addr)
	end
end