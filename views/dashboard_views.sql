/* Monthly summary */

CREATE OR REPLACE VIEW vw_user_monthly_summary AS
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
    u.monthly_income;


/* Budget alerts */

CREATE OR REPLACE VIEW vw_budget_alerts AS
SELECT
    u.full_name,
    c.category_name,
    b.budget_limot,

    SUM(COALESCE(t.amount, 0)) AS actual_spend,

    b.budget_limot - SUM(COALESCE(t.amount, 0)) AS remaining,

    ROUND(
        (
            SUM(COALESCE(t.amount, 0))
            / NULLIF(b.budget_limot, 0)
        ) * 100,
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
    AND DATE_TRUNC('month', t.txn_date)
        = DATE_TRUNC('month', b.budget_month)

GROUP BY
    u.full_name,
    c.category_name,
    b.budget_limot

HAVING
    ROUND(
        (
            SUM(COALESCE(t.amount, 0))
            / NULLIF(b.budget_limot, 0)
        ) * 100,
        1
    ) > 90;


/* Top Spenders */

CREATE OR REPLACE VIEW vw_top_spenders AS
SELECT
    u.user_id,
    u.full_name,
    SUM(t.amount) AS total_spent
FROM transactions t
JOIN accounts a
    ON t.account_id = a.account_id
JOIN users u
    ON a.user_id = u.user_id
WHERE LOWER(t.txn_type) = 'debit'
GROUP BY
    u.user_id,
    u.full_name;


/*Testing */

SELECT * FROM vw_user_monthly_summary;

SELECT * FROM vw_budget_alerts;

SELECT *
FROM vw_top_spenders
ORDER BY total_spent DESC
LIMIT 10;
