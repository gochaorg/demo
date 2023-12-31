Соображения по структуре данных
============================================

По идее надо добавить ограничения

- Водители и диспетчеры 
    - имеют одинаковую структуру
        - можно засунуть в одну таблицу с доп полем - роль (водитель / диспетчер)
            - и добавить триггер и/или ограничение на проверку диапазона возможных значений
        - если сотрудник может сочетать несколько ролей, тогда
            - таблицы: роли и роль_сотрудник и сотрудник
                - роль_сотрудник
                    - колонки
                        - person_id - id сотрудника FK
                        - role_id - id роли
                    - ограничение уникальности unique (person_id, role_id)
    - дата рождения должна быть не больше текущей
        - в идеале минимальный возраст 14 лет
- Путевые листы
    - дата выезда должна быть не больше даты возврата
    - кол-во потребленного топлива должно быть 0 или больше
    - растояние должно быть больше 0
- Машины
    - пробег должно быть 0 или больше
    - дата прохождения ТО, не больше текущей
    - дата выпуска не больше текущей

Менее очивидные ограничения, но по идее их можно учитывать что бы выявить нарушения в данных

- один сотрудник в один момент времени (смену/день) может выполнять одну роль
- один человек может находиться только в одном месте (машина/путевка) в один момент времени
    - те не должно быть ситуаций код водитель выполняет две или более путевки в один момент времени
- машина не может находиться в двух местах одновременно
    - те не должно быть что магина с один и тем же номером выполняет две или более путевки в один момент времени
- возраст сотрудника должен находиться в пределах 14 .. 120 лет
- для индентификация человека недостаточно ФИО, минимально серия/номер паспорта