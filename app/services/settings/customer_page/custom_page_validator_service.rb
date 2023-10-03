module Settings
  module CustomerPage
    class CustomPageValidatorService
      include ActiveModel::Validations

      attr_reader :page_type, :page_url, :page_title

      def initialize(params)
        @page_type = params['page_type']
        @page_url = params['page_url']
        @page_title = params['page_title']
      end

      validates_presence_of :page_title, :page_url
      validates :page_type, presence: true, inclusion: { in: CustomerPageConstants::CUSTOM_PAGE_TYPES }
    end
  end
end
