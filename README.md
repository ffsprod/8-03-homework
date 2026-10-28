# Домашнее задание к занятию «SQL. Часть 2» - Нефедов Александр

## Задание 1

<details>
<summary>Текст задания</summary>

Одним запросом получите информацию о магазине, в котором обслуживается более 300 покупателей, и выведите:

- фамилию и имя сотрудника из этого магазина;
- город нахождения магазина;
- количество пользователей, закреплённых в этом магазине.

</details>

Подсчитаю количество покупателей каждого магазина и отберу магазины, в которых их больше 300. Затем добавлю информацию о сотрудниках и городе расположения магазина.

```sql
SELECT
    st.last_name AS staff_last_name,
    st.first_name AS staff_first_name,
    ci.city AS store_city,
    cc.customer_count
FROM store AS s
JOIN (
    SELECT
        store_id,
        COUNT(*) AS customer_count
    FROM customer
    GROUP BY store_id
    HAVING COUNT(*) > 300
) AS cc
    ON cc.store_id = s.store_id
JOIN staff AS st
    ON st.store_id = s.store_id
JOIN address AS a
    ON a.address_id = s.address_id
JOIN city AS ci
    ON ci.city_id = a.city_id;
```

Количество покупателей считается до соединения с сотрудниками, поэтому не зависит от количества сотрудников магазина. Город определяется по адресу магазина.

## Задание 2

<details>
<summary>Текст задания</summary>

Получите количество фильмов, продолжительность которых больше средней продолжительности всех фильмов.

</details>

Подзапрос вычисляет среднюю продолжительность фильмов. Основной запрос подсчитывает фильмы, продолжительность которых больше среднего значения.

```sql
SELECT
    COUNT(*) AS film_count
FROM film
WHERE length > (
    SELECT AVG(length)
    FROM film
);
```

Для сравнения используется поле `length` — продолжительность фильма в минутах. Поле `rental_duration` обозначает срок аренды и в этом расчёте не используется.

## Задание 3

<details>
<summary>Текст задания</summary>

Получите информацию, за какой месяц была получена наибольшая сумма платежей, и добавьте информацию по количеству аренд за этот месяц.

</details>

Отдельно подсчитаю сумму платежей и количество аренд по месяцам. Затем объединю результаты и выберу месяц с наибольшей суммой платежей.

```sql
WITH monthly_payments AS (
    SELECT
        DATE_FORMAT(payment_date, '%Y-%m') AS year_month,
        SUM(amount) AS total_payments
    FROM payment
    GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
),
monthly_rentals AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS year_month,
        COUNT(*) AS rental_count
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
)
SELECT
    mp.year_month AS payment_month,
    mp.total_payments,
    COALESCE(mr.rental_count, 0) AS rental_count
FROM monthly_payments AS mp
LEFT JOIN monthly_rentals AS mr
    ON mr.year_month = mp.year_month
ORDER BY
    mp.total_payments DESC,
    mp.year_month ASC
LIMIT 1;
```

Платежи учитываются по `payment_date`, аренды — по `rental_date`. Таким образом, выводится количество аренд, начавшихся в самом доходном месяце.

Формат `YYYY-MM` позволяет не объединять одинаковые месяцы разных лет. Предварительная группировка исключает перемножение строк платежей и аренд при соединении.

Если в выбранном месяце не было аренд, `COALESCE` вернёт `0`. Если несколько месяцев имеют одинаковую максимальную сумму платежей, будет выбран самый ранний из них.
````
