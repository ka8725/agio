require_relative '../monkey/patches'

using Agio::Monkey

module Agio
  Sale = Struct.new(:amount, :name, :rate, :date, :number, keyword_init: true) do
    def to_s
      "#{number}: #{date} #{amount.inspect} #{rate.inspect}"
    end
  end
end
