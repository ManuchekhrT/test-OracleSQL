SELECT
    o.id                                                  AS "Номер заказа",
    g.id                                                  AS "Номер товара",
    g.quantity                                            AS "Кол-во товара",
    g.price * g.quantity                                  AS "Стоимость товара",
    SUM(g.price * g.quantity) OVER (PARTITION BY o.id)    AS "Стоимость всего заказа",
    g.quantity / SUM(g.quantity) OVER (PARTITION BY o.id) AS "Вес товара в заказе"
FROM
    orders o
JOIN 
    goods g ON o.id = g.order_id
ORDER BY
    o.id, g.id;