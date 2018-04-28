require_relative './revenue'
require_relative './account_statement'
require_relative './repos/payments_repo'
require_relative './repos/sales_repo'
require_relative './models/payment'
require_relative './models/sale'
require 'table_print'

using Agio::Monkey

module Agio
  class Report
    class BigDecimalFormatter
      def format(value)
        return value unless value.is_a?(BigDecimal)
        value.inspect
      end
    end

    NameValueRow = Struct.new(:name, :value)

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

      puts 'ПОСТУПЛЕНИЯ'
      report_payments(@payments_repo.collection, @revenue.payments_collection)
      puts

      puts 'ОБЯЗАТЕЛЬНЫЕ ПРОДАЖИ'
      report_sales(@compulsory_sales_repo.collection, @revenue.compulsory_sales_collection)
      puts

      puts 'СВОБОДНЫЕ ПРОДАЖИ'
      report_sales(@free_sales_repo.collection, @revenue.free_sales_collection)
      puts

      puts "РАСЧЕТ"
      report_revenue(@revenue)
    end

    private

    def report_sales(sales, reported_sales)
      tp.set Sale,
        formatted_doc_number(reported_sales),
        :date,
        formatted_amount(:amount),
        formatted_amount(:rate)
      tp sales
    end

    def report_payments(payments, reported_payments)
      tp.set Payment,
        formatted_doc_number(reported_payments),
        :date,
        formatted_amount(:amount),
        formatted_amount(:rate),
        formatted_amount(:compulsory_sale),
        formatted_amount(:compulsory_amount),
        formatted_amount(:free_amount),
        formatted_amount(:gross)
      tp payments
    end

    def formatted_amount(field)
      {field => {formatters: [BigDecimalFormatter.new]}}
    end

    def formatted_doc_number(payments)
      {
        number: ->(p) {
          mark = payments.include?(p) ? '*' : ''
          "#{p.number}#{mark}"
        }
      }
    end

    def report_revenue(revenue)
      rows = [
        NameValueRow.new('ВАЛОВАЯ ВЫРУЧКА БЕЗ УЧЕТА КУРСОВОЙ РАЗНИЦЫ', revenue.payments_gross),
        NameValueRow.new('КУРСОВАЯ РАЗНИЦА', revenue.sales),
        NameValueRow.new('ВАЛОВАЯ ВЫРУЧКА СУММА', revenue.gross),
        NameValueRow.new('НАЛОГ 3%', revenue.fee(3))
      ]
      tp.set NameValueRow,
        {name: {width: 200}},
        formatted_amount(:value)

      tp rows
    end
  end
end
