use testdb;

with
    source_table as (
        select
            txn_id, customer_id, timestamp, DATE_FORMAT(timestamp, '%Y-%m') as `year_month`, ROUND(amount, 4) as amount, transaction_type
        from transaction
        order by customer_id, UNIX_TIMESTAMP(timestamp)
    ),
    customer_max_month as (
        select
            customer_id, transaction_type, max(`year_month`) as `year_month`
        from source_table
        group by
            customer_id, transaction_type
    ),
    result_table_1_unpivot as (
        select
            customer_id, `year_month`, transaction_type, sum(amount) as total_amount, count(txn_id) as total_transactions
        from source_table
        where (
                customer_id, transaction_type, `year_month`
            ) in (
                select
                    customer_id, transaction_type, `year_month`
                from customer_max_month
            )
        group by
            customer_id, `year_month`, transaction_type
        order by 1, 2
    ),
    result_table_1 as (
        select 
            customer_id,
            SUM(case when transaction_type = 'Card' then total_amount/total_transactions end) as card_avg,
            SUM(case when transaction_type = 'Check' then total_amount/total_transactions end) as check_avg,
            SUM(case when transaction_type = 'Deposit' then total_amount/total_transactions end) as Deposit_avg,
            SUM(case when transaction_type = 'Loan Payment' then total_amount/total_transactions end) as `Loan Payment_avg`,
            SUM(case when transaction_type = 'Transfer' then total_amount/total_transactions end) as Transfer_avg,
            SUM(case when transaction_type = 'Withdrawal' then total_amount/total_transactions end) as Withdrawal_avg,
            SUM(case when transaction_type = 'Card' then total_transactions end) as card_count,
            SUM(case when transaction_type = 'Check' then total_transactions end) as check_count,
            SUM(case when transaction_type = 'Deposit' then total_transactions end) as Deposit_count,
            SUM(case when transaction_type = 'Loan Payment' then total_transactions end) as `Loan Payment_count`,
            SUM(case when transaction_type = 'Transfer' then total_transactions end) as Transfer_count,
            SUM(case when transaction_type = 'Withdrawal' then total_transactions end) as Withdrawal_count
        from 
            result_table_1_unpivot
        group by 
            customer_id
    ),
    lbp_txn as (
        select
            a.*, lbp.amount as lbp_amount, lbp.transaction_type as lbp_transaction_type, lbp.timestamp as lbp_timestamp, lbp.txn_id as lbp_txn_id
        from
            source_table a
            join source_table lbp on a.customer_id = lbp.customer_id
            and lbp.timestamp between a.timestamp - interval 30 day and a.timestamp
        order by a.txn_id
    ),
    result_table_2 as (
        select 
                txn_id, 
                customer_id,
                AVG(case when lbp_transaction_type = 'Card' then lbp_amount end) as card_avg,
                AVG(case when lbp_transaction_type = 'Check' then lbp_amount end) as check_avg,
                AVG(case when lbp_transaction_type = 'Deposit' then lbp_amount end) as Deposit_avg,
                AVG(case when lbp_transaction_type = 'Loan Payment' then lbp_amount end) as `Loan Payment_avg`,
                AVG(case when lbp_transaction_type = 'Transfer' then lbp_amount end) as Transfer_avg,
                AVG(case when lbp_transaction_type = 'Withdrawal' then lbp_amount end) as Withdrawal_avg,
                SUM(case when lbp_transaction_type = 'Card' then 1 else 0 end) as card_count,
                SUM(case when lbp_transaction_type = 'Check' then 1 else 0 end) as check_count,
                SUM(case when lbp_transaction_type = 'Deposit' then 1 else 0 end) as Deposit_count,
                SUM(case when lbp_transaction_type = 'Loan Payment' then 1 else 0 end) as `Loan Payment_count`,
                SUM(case when lbp_transaction_type = 'Transfer' then 1 else 0 end) as Transfer_count,
                SUM(case when lbp_transaction_type = 'Withdrawal' then 1 else 0 end) as Withdrawal_count
        from 
            lbp_txn
        group by 
            txn_id, customer_id
    ),
    latest_txn as (
        select customer_id, max(timestamp) as latest_txn
        from source_table
        group by customer_id  
    ),
    result_table_3 as (
        select 
            customer_id,
            AVG(case when lbp_transaction_type = 'Card' then lbp_amount end) as card_avg,
            AVG(case when lbp_transaction_type = 'Check' then lbp_amount end) as check_avg,
            AVG(case when lbp_transaction_type = 'Deposit' then lbp_amount end) as Deposit_avg,
            AVG(case when lbp_transaction_type = 'Loan Payment' then lbp_amount end) as `Loan Payment_avg`,
            AVG(case when lbp_transaction_type = 'Transfer' then lbp_amount end) as Transfer_avg,
            AVG(case when lbp_transaction_type = 'Withdrawal' then lbp_amount end) as Withdrawal_avg,
            SUM(case when lbp_transaction_type = 'Card' then 1 else 0 end) as card_count,
            SUM(case when lbp_transaction_type = 'Check' then 1 else 0 end) as check_count,
            SUM(case when lbp_transaction_type = 'Deposit' then 1 else 0 end) as Deposit_count,
            SUM(case when lbp_transaction_type = 'Loan Payment' then 1 else 0 end) as `Loan Payment_count`,
            SUM(case when lbp_transaction_type = 'Transfer' then 1 else 0 end) as Transfer_count,
            SUM(case when lbp_transaction_type = 'Withdrawal' then 1 else 0 end) as Withdrawal_count
        from lbp_txn
        where (customer_id, timestamp) in (select customer_id, latest_txn from latest_txn)
        group by txn_id, customer_id
        order by customer_id
    )
   select
    a.customer_id as customer_id,
    AVG(card_avg) as card_monthly_avg,
    AVG(check_avg) as check_monthly_avg,
    AVG(Deposit_avg) as Deposit_monthly_avg,
    AVG(`Loan Payment_avg`) as `Loan Payment_monthly_avg`,
    AVG(Transfer_avg) as Transfer_monthly_avg,
    AVG(Withdrawal_avg) as Withdrawal_monthly_avg,
    AVG(card_count) as card_monthly_count_avg,
    AVG(check_count) as check_monthly_count_avg,
    AVG(Deposit_count) as Deposit_monthly_count_avg,
    AVG(`Loan Payment_count`) as `Loan Payment_monthly_count_avg`,
    AVG(Transfer_count) as Transfer_monthly_count_avg,
    AVG(Withdrawal_count) as Withdrawal_monthly_count_avg
    from result_table_2 a
    group by a.customer_id
   ;

show TRIGGERs;

with
    source_table as (
        select
            txn_id, customer_id, timestamp, DATE_FORMAT(timestamp, '%Y-%m') as `year_month`, ROUND(amount, 4) as amount, transaction_type
        from transaction
        order by customer_id, UNIX_TIMESTAMP(timestamp)
    ),
    lbp_txn as (
        select
            a.*, lbp.amount as lbp_amount, lbp.transaction_type as lbp_transaction_type, lbp.timestamp as lbp_timestamp, lbp.txn_id as lbp_txn_id
        from
            source_table a
            join source_table lbp on a.customer_id = lbp.customer_id
            and lbp.timestamp between a.timestamp - interval 30 day and a.timestamp
        order by a.txn_id
    ),
    
select 
        txn_id, 
        customer_id,
        AVG(case when lbp_transaction_type = 'Card' then lbp_amount end) as card_avg,
        AVG(case when lbp_transaction_type = 'Check' then lbp_amount end) as check_avg,
        AVG(case when lbp_transaction_type = 'Deposit' then lbp_amount end) as Deposit_avg,
        AVG(case when lbp_transaction_type = 'Loan Payment' then lbp_amount end) as `Loan Payment_avg`,
        AVG(case when lbp_transaction_type = 'Transfer' then lbp_amount end) as Transfer_avg,
        AVG(case when lbp_transaction_type = 'Withdrawal' then lbp_amount end) as Withdrawal_avg,
        SUM(case when lbp_transaction_type = 'Card' then 1 else 0 end) as card_count,
        SUM(case when lbp_transaction_type = 'Check' then 1 else 0 end) as check_count,
        SUM(case when lbp_transaction_type = 'Deposit' then 1 else 0 end) as Deposit_count,
        SUM(case when lbp_transaction_type = 'Loan Payment' then 1 else 0 end) as `Loan Payment_count`,
        SUM(case when lbp_transaction_type = 'Transfer' then 1 else 0 end) as Transfer_count,
        SUM(case when lbp_transaction_type = 'Withdrawal' then 1 else 0 end) as Withdrawal_count
from 
    lbp_txn
group by 
    txn_id, customer_id;