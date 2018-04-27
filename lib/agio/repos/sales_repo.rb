require_relative './../models/sale'

module Agio
  class SalesRepo
    attr_reader :collection

    def initialize
      @collection = []
    end

    def push(data)
      return if collection.map(&:number).include?(data[:number])
      collection.push(Sale.new(data))
      collection.sort_by!(&:date)
    end
  end
end
