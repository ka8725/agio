require 'date'
require 'json'
require 'bigdecimal'
require 'net/http'

module Agio
  class AccountStatement
    BASE_DIR = './bank_files'

    PAYMENTS_FILE = "#{BASE_DIR}/payments.txt" # export of request #252 (converted to UTF-8)
    COMPULSARY_SALES_FILE = "#{BASE_DIR}/compulsory_sales.txt" # export of request #400 for BYR account (converted to UTF-8)
    FREE_SALES_FILE = "#{BASE_DIR}/free_sales.txt" # export of request #62 (converted to UTF-8)
    ROW_SEPARATOR = "###################################################\r\n"
    NBRB_URI = 'http://www.nbrb.by/API/ExRates/Rates/145?Periodicity=0&onDate=%{date}'

    def payments
      File.open(PAYMENTS_FILE).read.split(ROW_SEPARATOR).map do |payment|
        date = Date.parse(extract(payment, :DatePostup))
        {
          date: date,
          amount: BigDecimal(extract(payment, :SumPostup)),
          number: Integer(extract(payment, :Num)),
          rate: rate_on(date)
        }
      end
    end

    def compulsory_sales
      reports = File.open(COMPULSARY_SALES_FILE).read.split(ROW_SEPARATOR)
      sales = reports.flat_map do |report|
        docs = report.split(/(\^Num=\d+\^)/)[1..-1].each_slice(2).map(&:join)
        docs.grep(/\^DocID=000000001\^/)
      end

      sales.map do |sale|
        desc = extract(sale, :Nazn)
        {
          date: Date.parse(extract(sale, :OpDate)),
          amount: BigDecimal(amount_from_desc(desc, /USD (\d+([\.;]\d+)?)/)),
          number: Integer(extract(sale, :Num)),
          rate: BigDecimal(amount_from_desc(desc, /КУРС[У]? (\d+([\.;]\d+)?)/))
        }
      end
    end

    def free_sales
      File.open(FREE_SALES_FILE).read.split(ROW_SEPARATOR).map do |sale|
        {
          date: Date.parse(extract(sale, :DatePlt)),
          amount: BigDecimal(extract(sale, '004')),
          number: Integer(extract(sale, :N_plt)),
          rate: BigDecimal(extract(sale, :Course))
        }
      end
    end

    private

    def amount_from_desc(desc, reg)
      from_desc(desc, reg).sub(';', '.')
    end

    def from_desc(desc, reg)
      desc.scan(reg).first.first
    end

    def extract(str, field, value = /.*/)
      str.scan(/\^#{field}=(#{value})\^/).first.first
    end

    def rate_on(date)
      uri = URI(format(NBRB_URI, date: date))
      response = Net::HTTP.get(uri)
      JSON.parse(response)['Cur_OfficialRate']
    end
  end
end
