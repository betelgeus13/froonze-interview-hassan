class Premailer
  module Adapter
    # Nokogiri adapter
    module Nokogiri
      def inline_css
        to_inline_css.gsub('%7B', '{').gsub('%20', ' ').gsub('%7D', '}')
      end
    end
  end
end
