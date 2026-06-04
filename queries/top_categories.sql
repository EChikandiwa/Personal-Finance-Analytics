WITH ranked_spend AS (
    SELECT
        u.user_id,
        u.full_name,
        c.category_name,
        SUM(t.amount) AS total_spent,
        RANK() OVER (
            PARTITION BY u.user_id
            ORDER BY SUM(t.amount) DESC
        ) AS spend_rank
    FROM transactions t
    JOIN accounts a
        ON t.account_id = a.account_id
    JOIN users u
        ON a.user_id = u.user_id
    JOIN categories c
        ON t.category_id = c.category_id
    WHERE LOWER(t.txn_type) = 'debit'
    GROUP BY
        u.user_id,
        u.full_name,
        c.category_id,
        c.category_name
)
SELECT
    full_name,
    category_name,
    total_spent,
    spend_rank
FROM ranked_spend
WHERE spend_rank <= 3
ORDER BY
    full_name,
    spend_rank;
