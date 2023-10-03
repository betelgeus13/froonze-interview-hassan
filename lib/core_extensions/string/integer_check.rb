module CoreExtensions
  module String
    module IntegerCheck
      def is_integer?
        to_i.to_s == self
      end
    end
  end
end
