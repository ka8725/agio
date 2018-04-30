require 'yaml'
require 'singleton'
require 'forwardable'

module Agio
  class Config
    extend Forwardable
    include Singleton

    BankFilesConfig = Struct.new(
      :encoding,
      :directory_path,
      :payments_file_name,
      :compulsory_sales_file_name,
      :free_sales_file_name,
      keyword_init: true
    )

    def initialize
      @config = YAML.load(read_file)
    end

    def bank_files
      @bank_files ||= BankFilesConfig.new(@config[:bank_files])
    end

    def self.bank_files
      instance.bank_files
    end

    private

    def read_file
      File.open('config.local.yml').read if File.exists?('config.local.yml')
      File.open('config.yml').read if File.exists?('config.yml')
    end
  end
end
