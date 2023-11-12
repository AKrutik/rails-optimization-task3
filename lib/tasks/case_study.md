## Подготовка
Сразу решила обновить версию руби и рельс, т.к. в Ubuntu 22.04 используется openSSL v3, а заявленные вкерсии RoR отсутствует поддержка openSSL v3.

В ходе работы были использованы следующие инструменты:
- pghero
- rack-mini-profiler
- memory-profiler
- bullet
- rspec-benchmark
- rspec-sqlimit
- kaminary

# 1. Оптимизация выгрузки
Before:
```
example.json  0,16 с      136 MB
small.json    14,56 c     138 MB
medium.json   107,64 c    146 MB
large.json    1133,16 c   267 MB
```
Анализировать буду по загрузке small.json

1. Добавила `# frozen_string_literal: true`. Дало незначительный выйгрыш по времени.
2. По совету добавила `activerecord-import`, удалось выйграть еще пару секунд
3. Перенесла код в интерактор `ImportData` (давно хотела пощупать, что это), дабы было удобнее тестировать и запускать профайлеры
4. Сделала рефакторинг кода, сократив количество запросов в базу

After:
```
example.json  0,07 с      136 MB
small.json    1,64 c      147 MB
medium.json   5,03 c      188 MB
large.json    28,49 c     573 MB
```

Раздувание по памяти обусловлено тем, что все данные хранятся в хэше и уже потом сохраняются в базу, чтобы сократить количество запросов. Возможно, чтобы сократить раздувание следует использовать потоковую запись в БД.
Но ресурсы позволяют выделить такое количество памяти и удалось уложиться в бюджет.

# 2. Оптимизация запроса
Смотрим что рекомендует bullet

```
Completed 200 OK in 8337ms (Views: 7796.2ms | ActiveRecord: 519.5ms | Allocations: 4519308)

USE eager loading detected
  Trip => [:bus]
  Add to your query: .includes([:bus])
```

```
Completed 200 OK in 5107ms (Views: 4756.0ms | ActiveRecord: 338.4ms | Allocations: 3236113)

USE eager loading detected
  Bus => [:services]
  Add to your query: .includes([:services])
```

Добавила `.includes(bus: :services)`

Результат
`Completed 200 OK in 7545ms (Views: 7519.9ms | ActiveRecord: 22.5ms | Allocations: 4922897)`

Заменила на `.preload(bus: :services)`

Результат
`Completed 200 OK in 6541ms (Views: 6497.2ms | ActiveRecord: 33.0ms | Allocations: 4942174)`

Лучше, но отрисовка долгая.
Попробую использовать отрисовку коллекций и разделитель туда же впихнем `<%= render partial: "trip", collection: @trips, spacer_template: "delimiter" %>`

`Completed 200 OK in 6317ms (Views: 6277.2ms | ActiveRecord: 28.6ms | Allocations: 5334626)`

С сервисами поступим так же `<%= render partial: "service", collection: trip.bus.services %>`
`Completed 200 OK in 7029ms (Views: 7003.7ms | ActiveRecord: 22.0ms | Allocations: 6723074)`

Для ускорения прорисовки добавим пагинацию. Использую `gem 'kaminary'`. Теперь загрузка происходит бодрее, чтобы сильно не плодить страницы, ограничила их количество 6 шт.
`Completed 200 OK in 245ms (Views: 213.8ms | ActiveRecord: 27.3ms | Allocations: 172471)`

Думаю, пока этого достаточно :)

## Защита от регрессии

Для защиты от регрессии были написаны performace тесты.
