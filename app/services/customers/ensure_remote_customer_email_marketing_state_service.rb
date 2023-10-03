module Customers
  class EnsureRemoteCustomerEmailMarketingStateService
    class EnsureRemoteCustomerEmailMarketingStateServiceError < StandardError; end

    def self.call(remote_customer:)
      if remote_customer.email_marketing_consent.state.blank?
        remote_customer.email_marketing_consent.state = remote_customer.accepts_marketing ? 'subscribed' : 'unsubscribed'
      end

      return unless remote_customer.email_marketing_consent.opt_in_level.blank?

      remote_customer.email_marketing_consent.opt_in_level = 'single_opt_in'
    end
  end
end
