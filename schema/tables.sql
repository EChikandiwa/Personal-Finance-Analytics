CREATE TABLE users(
  user_id INT PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  city VARCHAR(60),
  created_at DATE,
  monthly_income DECIMAL(10,2)
);

CREATE TABLE accounts(
  account_id INT PRIMARY KEY,
  user_id INT NOT NULL,
  account_type VARCHAR(20),
  balance DECIMAL(12,2),
  opened_at DATE,
  is_active BOOLEAN,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE categories (
  category_id INT PRIMARY KEY,
  category_name VARCHAR(60) NOT NULL,
  categgory_type VARCHAR(20)
);

CREATE TABLE transactions(
  txn_id INT PRIMARY KEY,
  account_id INT NOT NULL,
  category_id INT,
  txn_date DATE,
  amount DECIMAL(10,2),
  description VARCHAR(200),
  txn_type VARCHAR(10),
  FOREIGN KEY (account_id) REFERENCES accounts(account_id),
  FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE budgets (
  budget_id INT PRIMARY KEY,
  user_id INT NOT NULL,
  category_id INT NOT NULL,
  budget_month DATE,
  budget_limot DECIMAL(10,2),
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY(category_id) REFERENCES categories(category_id)
);

