# я не был до конца уверен в условии, поэтому, руководствуясь своей логикой,
# создал view по принципу, что книга (элемент book_catalog) не просто содержит в себе роман,
# а состоит лишь из одного романа

create view novels as
select book_catalog.*, product.type
from book_catalog,
     content,
     product
where book_catalog.edition_code = content.product
  and content.book = product.id
  and product.type = 'Роман'
  and book_catalog.edition_code in
      (select content.product
       from content
       group by content.product
       having count(*) = 1)
group by edition_code;

# это представление я создал скорее для теста, чтоб посмотреть updatable view,
# по-сути это список книг (элементов book_catalog), которые содержат в себе хотя бы один роман

create view novels2 as
select book_catalog.*, product.type
from book_catalog,
     content,
     product
where book_catalog.edition_code = content.product
  and content.book = product.id
  and product.type = 'Роман';

# тут вроде всё понятно, просто набор авторов, количество их книг и количество их публикаций

create view authors_activity as
select authors.surname,
       authors.name,
       authors.patronymic,
       COUNT(distinct product.id)                  number_of_products,
       COUNT(distinct book_catalog.edition_code) number_of_publishments
from book_catalog,
     content,
     product,
     book_authors,
     authors
where book_catalog.edition_code = content.product
  and content.book = product.id
  and product.id = book_authors.book
  and book_authors.author = authors.id
group by authors.surname,
         authors.name,
         authors.patronymic;

# в этом задании я не включаю в view авторов, которые хоть раз имели соавтора

create view authors_without_coauthors as
select distinct authors.*
from authors,
     book_authors
where authors.id = book_authors.author
  and authors.id not in
      (select book_authors.author
       from book_authors
       where book_authors.book in
             (select book_authors.book
              from book_authors
              group by book_authors.book
              having count(book_authors.author) > 1
             ));


update novels                                   # update не сработает, тк изначально, при создании представления,
set name = 'War and Peace'                      # использовались агрегирующие функции, having и group by
where edition_code = 'edition001';

update novels2                                  # а здесь update сработает, тк команда модификации изменит одну и
set name = 'War and Peace'                      # только одну строку основной таблицы за раз, те для создания этого представления
where edition_code = 'edition001';              # не использовались агрегирующие функции, having, group by и distinct

insert into novels (edition_code, name, publisher,      # insert не сработает, тк изначально, при создании представления,
                    publishment_year, pages, type)      # использовались агрегирующие функции, having и group by
values ('edition000', 'kek', 'kek', 1488, 234, 'kek');

update authors_activity                                 # update не сработает, тк изначально, при создании представления,
set name = 'Neil'                                       # использовались агрегирующие функции, having, group by и distinct
where name = 'Нил';

update authors_without_coauthors                        # update не сработает, тк изначально, при создании представления,
set name = 'Tolstoy'                                    # использовались агрегирующие функции, having, group by и distinct
where id = 1;