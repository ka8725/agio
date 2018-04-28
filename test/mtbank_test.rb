require 'test_helper'

class MtbankTest < Minitest::Test
  class Agio::AccountStatement
    BASE_DIR = './test/bank_files/mtbank'
  end

  def test_mtbank
    puts Agio::AccountStatement::BASE_DIR
    filter = {start_date: Date.parse('2018-01-03'), end_date: Date.parse('2018-03-31')}
    Agio::Report.new(filter).run
  end
end
