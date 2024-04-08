use testdb;

DROP TABLE IF EXISTS account_profile;


-- Stord procedure to calculate the average and count of each transaction type for each customer
CREATE TABLE
    account_profile (
        customer_id BIGINT PRIMARY KEY,
        card_avg decimal(10, 2),
        check_avg decimal(10, 2),
        deposit_avg decimal(10, 2),
        `loan payment_avg` decimal(10, 2),
        transfer_avg decimal(10, 2),
        withdrawal_avg decimal(10, 2),
        card_count int,
        check_count int,
        deposit_count int,
        `loan payment_count` int,
        transfer_count int,
        wihdrawal_count int
    );

DROP PROCEDURE IF EXISTS account_Profile;

CREATE PROCEDURE account_Profile()
    BEGIN
        INSERT INTO account_profile
            select
                customer_id,
                ROUND(AVG(case when transaction_type = 'Card' then amount end), 2) as card_avg,
                ROUND(AVG(case when transaction_type = 'Check' then amount end), 2) as check_avg,
                ROUND(AVG(case when transaction_type = 'Deposit' then amount end), 2) as Deposit_avg,
                ROUND(AVG(case when transaction_type = 'Loan Payment' then amount end), 2) as `Loan Payment_avg`,
                ROUND(AVG(case when transaction_type = 'Transfer' then amount end), 2) as Transfer_avg,
                ROUND(AVG(case when transaction_type = 'Withdrawal' then amount end), 2) as Withdrawal_avg,
                SUM(case when transaction_type = 'Card' then 1 else 0 end)as card_count,
                SUM(case when transaction_type = 'Check' then 1 else 0 end)as check_count,
                SUM(case when transaction_type = 'Deposit' then 1 else 0 end)as Deposit_count,
                SUM(case when transaction_type = 'Loan Payment' then 1 else 0 end)as `Loan Payment_count`,
                SUM(case when transaction_type = 'Transfer' then 1 else 0 end)as Transfer_count,
                SUM(case when transaction_type = 'Withdrawal' then 1 else 0 end)as Withdrawal_count
            from transaction
            group by customer_id
            order by customer_id
        ON DUPLICATE KEY UPDATE
            card_avg = values(card_avg),
            check_avg = values(check_avg),
            deposit_avg = values(deposit_avg),
            `loan payment_avg` = values(`loan payment_avg`),
            transfer_avg = values(transfer_avg),
            withdrawal_avg = values(withdrawal_avg),
            card_count = values(card_count),
            check_count = values(check_count),
            deposit_count = values(deposit_count),
            `loan payment_count` = values(`loan payment_count`),
            transfer_count = values(transfer_count),
            wihdrawal_count = values(wihdrawal_count);
    END;

-- Trigger to update the account_profile table after each insert on the transaction table
DROP TRIGGER IF EXISTS account_profile_update;

CREATE TRIGGER account_profile_update AFTER INSERT ON transaction FOR EACH ROW BEGIN CALL account_profile ();

END;