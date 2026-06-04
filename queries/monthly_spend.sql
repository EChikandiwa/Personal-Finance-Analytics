SELECT
    u.full_name,
    c.category_name,
    TO_CHAR(t.txn_date, 'YYYY-MM') AS month,
    SUM(t.amount) AS total_spent
FROM transactions t
JOIN accounts a
    ON t.account_id = a.account_id
JOIN users u
    ON a.user_id = u.user_id
JOIN categories c
    ON t.category_id = c.category_id
WHERE LOWER(t.txn_type) = 'debit'
GROUP BY
    u.full_name,
    c.category_name,
    TO_CHAR(t.txn_date, 'YYYY-MM')
ORDER BY
    month,
    total_spent DESC;
