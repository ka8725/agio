require_relative '../monkey/patches'

using Agio::Monkey

module Agio
  Payment = Struct.new(:amount, :date, :rate, :number, keyword_init: true) do
    COMPULSARY_SALE = 10 # in percents

    def compulsory_sale
      COMPULSARY_SALE / 100.0
    end

    def free_amount
      amount - compulsory_amount
    end

    def compulsory_amount
      (amount * compulsory_sale).round(2)
    end

    def gross
      amount * rate
    end

    def to_s
      "#{number}: #{date} #{amount.inspect} #{rate.inspect} #{compulsory_amount.inspect} #{free_amount.inspect}"
    end
  end
end
