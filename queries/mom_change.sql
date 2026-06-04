WITH monthly AS (
    SELECT
        u.full_name,
        TO_CHAR(t.txn_date, 'YYYY-MM') AS month,
        SUM(t.amount) AS total_spent
    FROM transactions t
    JOIN accounts a
        ON t.account_id = a.account_id
    JOIN users u
        ON a.user_id = u.user_id
    WHERE LOWER(t.txn_type) = 'debit'
    GROUP BY
        u.full_name,
        TO_CHAR(t.txn_date, 'YYYY-MM')
)
SELECT
    full_name,
    month,
    total_spent,
    LAG(total_spent) OVER (
        PARTITION BY full_name
        ORDER BY month
    ) AS prev_month,
    total_spent -
    LAG(total_spent) OVER (
        PARTITION BY full_name
        ORDER BY month
    ) AS mom_change
FROM monthly
ORDER BY
    full_name,
    month;
