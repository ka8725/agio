require_relative './revenue'
require_relative './account_statement'
require_relative './repos/payments_repo'
require_relative './repos/sales_repo'

module Agio
  class Process
    def initialize(start_date:, end_date:)
      @filter = {start_date: start_date, end_date: end_date}
      @start_date = start_date
      @end_date = end_date

      @account_statement = AccountStatement.new
      @payments_repo = PaymentsRepo.new
      @compulsory_sales_repo = SalesRepo.new
      @free_sales_repo = SalesRepo.new
    end

    def run
      @account_statement.payments.each { |data| @payments_repo.push(data) }
      @account_statement.compulsory_sales.each { |data| @compulsory_sales_repo.push(data) }
      @account_statement.free_sales.each { |data| @free_sales_repo.push(data) }

      @revenue = Revenue.new(@payments_repo, @compulsory_sales_repo, @free_sales_repo, @filter)

      puts 'Payments:'
      @payments_repo.collection.each { |p| puts p }

      puts 'Compulsary sales:'
      @compulsory_sales_repo.collection.each { |p| puts p }

      puts 'Free sales:'
      @free_sales_repo.collection.each { |p| puts p }
    end
  end
end
