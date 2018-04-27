require 'bigdecimal'

module Agio
  module Monkey
    refine BigDecimal do
      def inspect
        to_s('F')
      end
    end
  end
end
