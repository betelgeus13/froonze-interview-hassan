module Shops
  class ActiveShopIdsIteratorService

    PER_BATCH = 1000 # this is to control memory footprint of iterating through all shop ids

    def self.iterate(&block)
      max_id = Shop.maximum(:id)

      (1..max_id).step(PER_BATCH).each do |low|
        shop_id_list(low).each do |shop_id|
          block.call(shop_id)
        end
      end
    end

    private

    def self.shop_id_list(low)
      high = low + PER_BATCH
      shop_id_list = Shop.installed.with_active_plan
         .where(id: (low...high))
         .pluck(:id)
      shop_id_list
    end

  end
end
