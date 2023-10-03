# Service used to count wishlist notifications for each customer done within a job
module Wishlists
  class CustomerNotificationLockService
    def self.update_count(customer_id:)
      $redis.multi do
        $redis.incr("wishlist_notification:#{customer_id}")
        $redis.expire("wishlist_notification:#{customer_id}", 10.minutes)
      end.first
    end

    def self.exceed_limit?(customer_id:, limit: 1)
      $redis.get("wishlist_notification:#{customer_id}").to_i >= limit
    end

    def self.remove_lock(customer_id:)
      $redis.del("wishlist_notification:#{customer_id}")
    end
  end
end
