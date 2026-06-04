SELECT
    u.full_name,
    c.category_name,
    b.budget_limot,
    SUM(COALESCE(t.amount, 0)) AS actual_spend,
    b.budget_limot - SUM(COALESCE(t.amount, 0)) AS remaining,
    ROUND(
        (SUM(COALESCE(t.amount, 0)) / b.budget_limot * 100)::numeric,
        1
    ) AS pct_used
FROM budgets b
JOIN users u
    ON b.user_id = u.user_id
JOIN categories c
    ON b.category_id = c.category_id
LEFT JOIN accounts a
    ON a.user_id = u.user_id
LEFT JOIN transactions t
    ON t.account_id = a.account_id
    AND t.category_id = b.category_id
    AND LOWER(t.txn_type) = 'debit'
    AND TO_CHAR(t.txn_date, 'YYYY-MM')
        = TO_CHAR(b.budget_month, 'YYYY-MM')
GROUP BY
    u.full_name,
    c.category_name,
    b.budget_limot
HAVING
    SUM(COALESCE(t.amount, 0)) > b.budget_limot
ORDER BY
    pct_used DESC;
