# Agio

Инструментарий для расчета курсовой разницы, образовавшейся вследствии продажи валюты в день, отличный от дня поступления валюты на счет юридического лица. Расчет основан на определенных (см. ниже) выписках из системы "Клиент-Банк" юридических лиц и необходим для правильного заполнения валовой выручки на территории Республики Беларусь.

## Использование

1. Для начала необходимо экспортировать необходимые выписки из системы "Клиент-Банк":
  - №400 для счета в BYR (счет, на который идут поступления после продажи валюты) в файл `payments.txt`;
  - №62 - платежи свободной продажи в файл `free_sales.txt`;
  - №252 - сведения о поступлении платежей в валюте в файл `compulsory_sales.txt`.

1. Выставить кодировку файлам UTF-8 (открыть файл через F4 и сохранить файл с новой кодировкой).
1. Переместить файлы в `./bank_files`.
1. Запустить скрипт:

```ruby
require 'agio'

filter = {start_date: Date.parse('2018-01-03'), end_date: Date.parse('2018-03-31')}
Agio::Process.new(filter).run
```

Вывод производится в текстовом виде в консоль.

## Органичения

1. Только для юр. лиц и индивидуальных предпринимателей Республики Беларусь;
1. Протестировано только на МТБанк в системе "Электронные платежи (клиент) v 2.61.45.00";
1. размер обязательной продажи выставлен как константа и равен 10%.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ka8725/agio. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
