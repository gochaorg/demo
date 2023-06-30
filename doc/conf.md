﻿Конфигурация
=====================

Конфигурация задается в файле `config.ini`, 
который должен распологаться в текущем каталоге.

Файл содержит следующую структуру

- Секция `[db]`
    - Ключ `connection-string`
        - Обязательное Значение - содержит строку подключения к СУБД
        - Пример
                `Provider=SQLOLEDB.1;Persist Security Info=False;User ID=test;Initial Catalog=test1;Data Source=localhost`
    - Ключ `user-name`
        - Обязательное Значение - содержит имя пользователя СУБД
    - Ключ `password`
        - Обязательное Значение - содержит пароль пользователя СУБД
- Секция `[word]`
    - Ключ `template`
        - Не обязательное значение - путь шаблону, значение '-' (тире без ковычек) - указывает, что шаблон отсуствует
    - Ключ `insertInto`
        - Не обязательное значение - указывает имя закладки в шаблоне, куда будет добавлена таблица
- Секция `[excel]`
    - Ключ `template`
        - Не обязательное значение - путь шаблону, значение '-' (тире без ковычек) - указывает, что шаблон отсуствует

Строка подключения
-------------------------

[Полное описание синтаксиса тут](https://learn.microsoft.com/en-us/dotnet/framework/data/adonet/connection-string-syntax)

На примере

    Provider=SQLOLEDB.1;Persist Security Info=False;User ID=test;Initial Catalog=test1;Data Source=localhost

Значение 
    - `Data Source` - указывает на имя хоста содержажего СУБД
    - `User ID` - имя пользователя
    - `Initial Catalog` - имя СУБД