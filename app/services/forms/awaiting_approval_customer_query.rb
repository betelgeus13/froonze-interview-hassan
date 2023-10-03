module Forms
  class AwaitingApprovalCustomerQuery
    def call(shop:, query:)
      db_query = shop.awaiting_approval_customers
      return db_query unless query.present?

      query = "%#{query}%"
      db_query.where('email ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ?', query, query, query)
    end
  end
end
