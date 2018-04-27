require_relative './../models/payment'

module Agio
  class PaymentsRepo
    attr_reader :collection

    def initialize
      @collection = []
    end

    def push(data)
      return if collection.map(&:number).include?(data[:number])
      collection.push(Payment.new(data))
      collection.sort_by!(&:date)
    end
  end
end
