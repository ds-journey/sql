# Проектирование структуры БД

- [Скрипт создания таблиц](https://github.com/ds-journey/sql/blob/main/create.sql)
- [Скрипт добавления данных](https://github.com/ds-journey/sql/blob/main/init.sql)

![dbSchema](https://github.com/ds-journey/sql/blob/main/schema.png)

Требования 1NF:
- значения всех атрибутов отношения атомарны(неделимы)
- все неключевые атрибуты отношения находятся в функциональной зависимости от первичного ключа. То есть 
  конкретному набору значений ключевых атрибутов соответствует только один кортеж отношения (требование неповторяющихся строк)

Требования 2NF:
- отношение находится в 1NF
- каждый неключевой атрибут функционально полно зависит от первичного ключа (когда первичный ключ составной)

Требования 3NF:
- отношение находится во 2NF
- отсутствуют транзитивные функциональные зависимости

Таблицы из файла находятся в 1NF, если за первичный ключ принять атрибуты transaction_id и customer_id.
Требования 2NF уже не выполняются, следовательно не выполняются и требования 3NF

В ходе проектирования структуры БД было выделено

Таблицы - справочники (соответствуют 3NF):
1. country
2. gender
3. wealt_segment
4. job_industry_category
5. brand
6. product_line
7. product_class
8. product_size

Все эти таблицы имеют по 1 столбцу-атрибуту, который является первичным ключом и, следовательно, гарантирует уникальность значений. 

Таблицы (соответствуют 2NF):
1. address 
2. customer
3. transaction
4. product
