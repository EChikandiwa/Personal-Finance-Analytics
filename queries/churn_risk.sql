SELECT
    u.user_id,
    u.full_name,
    u.email,
    MAX(t.txn_date) AS last_transaction,
    CURRENT_DATE - MAX(t.txn_date) AS days_since_last
FROM users u
JOIN accounts a
    ON a.user_id = u.user_id
JOIN transactions t
    ON t.account_id = a.account_id
GROUP BY
    u.user_id,
    u.full_name,
    u.email
HAVING
    CURRENT_DATE - MAX(t.txn_date) > 60
ORDER BY
    days_since_last DESC;
