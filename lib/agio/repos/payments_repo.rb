require_relative './../models/payment'
require 'forwardable'

module Agio
  class PaymentsRepo
    extend Forwardable

    attr_reader :collection

    def_delegator :collection, :each

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
