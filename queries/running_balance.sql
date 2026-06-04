SELECT
    a.account_id, u.full_name, t.txn_date,
    t.description,
    t.txn_type,
  CASE
        WHEN LOWER(t.txn_type) = 'credit' THEN t.amount
        ELSE -t.amount
    END AS net_amount,
    SUM(
        CASE
            WHEN LOWER(t.txn_type) = 'credit' THEN t.amount
            ELSE -t.amount
        END
    ) OVER (
        PARTITION BY a.account_id
        ORDER BY t.txn_date, t.txn_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_balance
FROM transactions t
JOIN accounts a
    ON t.account_id = a.account_id
JOIN users u
    ON a.user_id = u.user_id
ORDER BY
    a.account_id,
    t.txn_date,
    t.txn_id;

SELECT
    u.user_id,
    u.full_name,

    SUM(
        CASE
            WHEN LOWER(t.txn_type) = 'credit'
            THEN t.amount
            ELSE 0
        END
    ) AS total_income,

    SUM(
        CASE
            WHEN LOWER(t.txn_type) = 'debit'
            THEN t.amount
            ELSE 0
        END
    ) AS total_expenses,

    SUM(
        CASE
            WHEN LOWER(t.txn_type) = 'credit'
            THEN t.amount
            ELSE -t.amount
        END
    ) AS net_savings,

    u.monthly_income,

    ROUND(
        (
            SUM(
                CASE
                    WHEN LOWER(t.txn_type) = 'debit'
                    THEN t.amount
                    ELSE 0
                END
            ) / NULLIF(u.monthly_income, 0)
        ) * 100,
        1
    ) AS expense_pct_of_income

FROM users u
JOIN accounts a
    ON u.user_id = a.user_id
JOIN transactions t
    ON a.account_id = t.account_id

GROUP BY
    u.user_id,
    u.full_name,
    u.monthly_income

ORDER BY
    net_savings DESC;
