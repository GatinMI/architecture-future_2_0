# Задание 4. Моделирование домена и интеграций

Артефакты:

| Файл | Что это |
|------|---------|
| [bounded-contexts.puml](bounded-contexts.puml) / [.png](bounded-contexts.png) | Схема bounded contexts (context map): 8 доменов + легаси-мосты и медицинская зона, связи по паттернам DDD (Customer/Supplier, Conformist, ACL) |
| [event-storming.puml](event-storming.puml) / [.png](event-storming.png) | Event Storming (эквивалент): источники событий -> событийный бэкбон (Kafka + Schema Registry + DLQ) -> подписчики; события, агрегаты, подписки |
| [aggregates.md](aggregates.md) | Агрегаты по контекстам: границы, инварианты, ключи, события |
| [events.md](events.md) | Каталог доменных событий: имя, контекст-источник, семантика, минимальный контракт, подписчики; envelope и правила схем; матрица подписок |
| [justification.md](justification.md) | Обоснование событийного подхода vs Camel/DWH: гибкость, масштабируемость, скорость, что отдаём, план перехода |
