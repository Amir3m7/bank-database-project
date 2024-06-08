CREATE TABLE users (
    
    id SERIAL PRIMARY KEY,  
    name VARCHAR(255) NOT NULL,
    username varchar(100) not null unique,  
    password varchar(50) not null
);

CREATE TABLE accounts (
    account_number VARCHAR(255) NOT NULL PRIMARY key,
    ammount DECIMAL(10,2) check (ammount>0),
    blocked BOOLEAN NOT NULL DEFAULT FALSE CHECK (blocked IN (TRUE, FALSE)),
    user_id INT NOT NULL,
    date_created TIMESTAMP default CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(id) on delete cascade 
);


CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    src_account VARCHAR(255) NOT NULL,
    des_account varchar(200) not null,
    amount DECIMAL(10,2),
    date_created TIMESTAMP NOT NULL default CURRENT_TIMESTAMP,
    src_balance decimal(10,2),
    des_balance decimal(10,2),
    FOREIGN KEY(src_account) REFERENCES accounts(account_number)
);




CREATE TABLE loans (
    id SERIAL PRIMARY KEY,
    loan_amount DECIMAL(10,2) check(loan_amount>0),
    interest_rate DECIMAL(10,2),
    duration INT NOT NULL,
    account varchar(20),
    user_id INT NOT NULL,
    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN key(account) REFERENCES accounts(account_number)
);



CREATE TABLE payments_of_loan (
    id SERIAL PRIMARY KEY,
    payment_amount DECIMAL(10,2),
    loan_id INT NOT NULL,
    part integer,
    date_to_paid TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    bolean_paid BOOLEAN default false,
    FOREIGN KEY(loan_id) REFERENCES loans(id)
);


insert into users(id,username,name,PASSWORD)
values (1,'am_i','amir','1234'),
 (2,'mhmd_gh','mohammad','1342'),
 (3,'aliii','ali','1234354'),
 (4,'sasi','sasan','5t4232'),
 (5,'ashi','ashkan','3241'),
 (6,'moji','mojtaba','evfads'),
 (7,'sara7575','sara','retb'),
 (8,'saghar','saghar','fedsq'),
 (9,'am_ir_ali','amirali','v4r23'),
 (10,'amir_mohammad','amirmohammad','4321p');
 
 -- Sample INSERT queries for the accounts table
INSERT INTO accounts (account_number, ammount, blocked, user_id) VALUES 
    ('123456789', 1000.00, FALSE, 1),
    ('987654321', 500.50, TRUE, 2),
    ('111223344', 7500.00, FALSE, 3),
    ('555666777', 120.75, FALSE, 4),
    ('999000111', 3000.00, TRUE, 5),
    ('777888999', 800.50, FALSE, 6),
    ('444333222', 150.00, TRUE, 7),
    ('222111000', 2500.75, FALSE, 8),
    ('888777666', 600.00, FALSE, 9),
    ('666555444', 4000.25, TRUE, 10),
    ('111111111',20000.00,false,1),
    ('111111112',1000.00,false,1),
    ('111111122',20000.00,false,3),
    ('999999999',12000.00,false,2),
    ('444444444',1200.00,false,4);

-- select * from TRANSACTIONs
-- INSERT INTO transactions (src_account, des_account, amount, date_created) VALUES
--   ('123456789', '987654321', 250.00, '2023-10-04 12:00:00'),
--   ('555666777', '999000111', 500.00, '2023-09-28 14:30:00'),
--   ('777888999', '444333222', 75.00, '2023-11-01 08:15:00'),
--   ('222111000', '888777666', 100.00, '2023-10-23 20:00:00'),
--   ('666555444', '111111122', 1500.00, '2023-12-12 16:30:00'),
--   ('111111122', '111223344', 1000.00, '2023-11-25 10:00:00'),
--   ('111223344', '555666777', 200.00, '2023-10-08 16:00:00'),
--   ('987654321', '222111000', 300.00, '2023-11-05 12:45:00'),
--   ('123456789', '777888999', 400.00, '2023-12-02 18:00:00'),
--   ('888777666', '666555444', 500.00, '2023-10-31 09:30:00');


create or replace function get_id(user_name varchar(20))
returns integer 
as 
$$
declare user_id integer;
begin
    select id into user_id from users where username=user_name ;
    return user_id;
end;
$$language plpgsql;

--select get_id('am_i');
 
 
CREATE OR REPLACE FUNCTION login_user(
    p_username VARCHAR(255),
    p_password VARCHAR(255)
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    hashed_password VARCHAR(255);
BEGIN
    
    SELECT password INTO hashed_password
    FROM users
    WHERE username = p_username;
    
    raise notice '%',hashed_password;
   
    IF hashed_password=p_password THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$;
-- select * from users
-- select login_user('am_i','12')
--select login_user('am_i','123')
--select login_user('am_i','8585')

--select login_user('mhmd_gh','1342')



CREATE OR REPLACE FUNCTION change_password(
  p_user_id INT,
  p_previous_password VARCHAR(255),
  p_new_password VARCHAR(255)
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
  previous_password VARCHAR(255);
BEGIN
  SELECT password INTO previous_password
  FROM users
  WHERE id = p_user_id and password=p_previous_password;

  IF previous_password IS NOT NULL THEN
    UPDATE users
    SET password=p_new_password
    WHERE id = p_user_id;
    RETURN TRUE;
  ELSE
    RETURN FALSE; 
  END IF;
END;
$$;


-- select change_password(2,'1234','1342')
-- select * from users

CREATE OR REPLACE FUNCTION account_info(id_user INTEGER)
RETURNS TABLE (
  id INTEGER,
  account VARCHAR(255)
)
AS
$$
BEGIN
  RETURN QUERY
  SELECT user_id, account_number
  FROM accounts
  WHERE user_id = id_user;
END;
$$ LANGUAGE plpgsql;

-- select * from account_info(1)
-- select * from account_info(2)




create or replace function all_account_with_info(user_name varchar(20))
returns table(
id integer,
account varchar(20),
block BOOLEAN,
balance decimal(10,2),
date_create timestamp
)
as
$$
BEGIN
    return query 
    select u.id,account_number,blocked,ammount,date_created
    from users as u inner join accounts as a on 
    u.id=a.user_id
    where username=user_name;
    
end;
$$language plpgsql;
-- select * from all_account_with_info('am_i')
-- 



create or replace function check_account_with_username(user_Name varchar(20),account varchar(20))
returns BOOLEAN 
as 
$$
declare u_name varchar(20);
begin
    select username into u_name 
    from users inner join accounts 
    on id=user_id
    where username=user_name and account_number=account ;
    
    if u_name is not null then return true;
    else return false;
    end if;

end;
$$language plpgsql;
-- select check_account_with_username('am_i','123456789')
-- select check_account_with_username('am_i','987654321')



CREATE OR REPLACE FUNCTION get_recent_transactions(
  account_number VARCHAR(255),
  number INTEGER
)
RETURNS TABLE (
  transaction_id INT,
  src_acc VARCHAR(255),
  des_acc VARCHAR(255),
  amnt DECIMAL(10,2),
  paid_date TIMESTAMP
)
AS
$$
BEGIN  
  RETURN QUERY
    SELECT
    id,src_account ,des_account , amount , date_created
    from transactions 
    where src_account=account_number or des_account=account_number
    order by date_created desc
    limit number;

END;
$$ LANGUAGE plpgsql;
select * from transactions;


create or REPLACE function get_transaction_with_date(account varchar(20),start_time date ,end_time date)
returns table (
    acc varchar(20),
    transaction_date date,
    balance decimal(10,2)
)
as 
$$
begin 
    return query
    select src_account as account_number ,cast (date_created as date) as date_t,src_balance from transactions
    where src_account=account and date_created between cast(start_time - interval '1 day' as date) and cast(end_time + interval '1 day' as date)
    union all
    select des_account as account_number ,cast (date_created as date) as date_t,des_balance from transactions
    where des_account=account and date_created between cast(start_time - interval '1 day' as date) and cast(end_time + interval '1 day' as date)
    order by date_t;
    
end;
$$language plpgsql;
--select * from get_transaction_with_date('888777666','2024-02-02','2024-02-04')


CREATE OR REPLACE FUNCTION account_information(account varchar(255))
returns TABLE (
    id integer,
    name varchar(255),
    accountNumber varchar(255),
    ammount DECIMAL(10,2),
    blocked BOOLEAN,
    date_create TIMESTAMP
)
AS
$$
BEGIN
    RETURN QUERY
    SELECT u.id,u.name,a.account_number ,a.ammount,a.blocked,a.date_created
    FROM accounts AS a
    JOIN users AS u ON a.user_id = u.id
    WHERE account_number = account;

END;
$$ LANGUAGE plpgsql;
-- select * from account_information('123456789')
-- select * from account_information('111111111')



CREATE OR REPLACE FUNCTION account_name(account varchar(255))
returns varchar(10)
AS
$$
declare user_name varchar(10);
BEGIN

    SELECT u.name into user_name
    FROM accounts AS a
    JOIN users AS u ON a.user_id = u.id
    WHERE account_number = account;
    return user_name;

END;
$$ LANGUAGE plpgsql;
-- select * from account_name('123456789')
-- 

CREATE OR REPLACE FUNCTION block_account(
  account VARCHAR(255)
)
RETURNS BOOLEAN
language plpgsql
AS 
$$
BEGIN
  -- Check if the account exists
  IF NOT EXISTS (
    SELECT account_number
    FROM accounts
    WHERE account_number = account
  ) THEN
    RETURN FALSE;
  END IF;

    UPDATE accounts
    SET blocked = TRUE
    WHERE account_number = account;
    return true;

  END;
$$;
-- select block_account('381281');
-- select block_account('123456789')



CREATE OR REPLACE FUNCTION unblock_account(
  account VARCHAR(255)
)
RETURNS BOOLEAN
language plpgsql
AS 
$$
BEGIN
  -- Check if the account exists
  IF NOT EXISTS (
    SELECT account_number
    FROM accounts
    WHERE account_number = account
  ) THEN
    RETURN FALSE;
  END IF;

    UPDATE accounts
    SET blocked = false
    WHERE account_number = account;
    return true;

  END;
$$;
-- select unblock_account('123456789')
-- select unblock_account('381281');



CREATE OR REPLACE function transaction(
    src_acc VARCHAR(255),
    des_acc VARCHAR(255),
    amnt DECIMAL(10,2))
returns BOOLEAN
LANGUAGE plpgsql
AS 
$$
declare balance decimal(10,2);
declare flag boolean;
declare updated_src_balance decimal(10,2);
declare updated_des_balance decimal(10,2);
BEGIN
    select ammount into balance from accounts where account_number=src_acc;
    select blocked into flag from accounts where account_number=src_acc;

    if balance<amnt or flag=true then return false;
    else 
    -- Subtract amount from source account
    UPDATE accounts
    SET ammount = ammount - amnt
    WHERE account_number = src_acc;

    -- Add amount to destination account
    UPDATE accounts
    SET ammount = ammount + amnt
    WHERE account_number = des_acc;


    select ammount into updated_src_balance from accounts where account_number=src_acc;
    select ammount into updated_des_balance from accounts where account_number=des_acc;
    -- Insert into transactions table
    INSERT INTO transactions (src_account, des_account, amount,src_balance,des_balance)
    VALUES (src_acc, des_acc, amnt,updated_src_balance,updated_des_balance );
    end if;
    -- Commit the transaction
    return true;

    COMMIT;

END;
$$;
 select transaction('888777666','111111112',20);
 select transaction('111111111','111111112',100);
 select transaction('123456789','111111111',50);
 select transaction('987654321','888777666',10);
 
 select transaction('111223344','111111112',20);
 select transaction('222111000','999000111',100);
 select transaction('444333222','111111111',50);
 select transaction('777888999','888777666',10);


CREATE OR REPLACE FUNCTION loan_point(account VARCHAR(20))
RETURNS decimal(10,2) 
LANGUAGE plpgsql
AS
$$
declare l_point decimal(10,2);
declare amnt decimal(10,2);
BEGIN
    select ammount into amnt from accounts where account_number=account;
    
    select min(balance) into l_point 
    from get_transaction_with_date(account ,cast(current_date - interval '2 month' as date),current_date);
    if l_point is null then 
    return amnt;
    else 
    return l_point;
    end if;
END;
$$;

-- select * from get_transaction_with_date('888777666',  cast(current_date - interval '2 month' as date),current_date)
-- select loan_point('111111112')



 
create or replace FUNCTION get_loan(acc varchar(20))
returns BOOLEAN
language plpgsql
as
$$
declare
    loan_amnt decimal;
    u_id integer;
    loan_id integer;
    loan_id2 integer;
begin
    
    select id into loan_id from loans where account=acc;
    if loan_id is null then

    select loan_point(acc) into loan_amnt;
    select user_id into u_id from accounts where account_number = acc;

    update accounts
    set ammount = ammount + loan_amnt
    where account_number = acc;

    insert into loans(loan_amount,interest_rate,duration,user_id,account)
    values (loan_amnt,1.2,12,u_id,acc);
     
    select id into loan_id2 from loans where account=acc;
    insert into payments_of_loan(payment_amount,loan_id,part,date_to_paid,bolean_paid)
    values
    (null,loan_id2,1,current_date,false),
    (null,loan_id2,2,cast(current_date+interval '1 month' as date),false),
    (null,loan_id2,3,cast(current_date+interval '2 month' as date),false),
    (null,loan_id2,4,cast(current_date+interval '3 month' as date),false),
    (null,loan_id2,5,cast(current_date+interval '4 month' as date),false),
    (null,loan_id2,6,cast(current_date+interval '5 month' as date),false),
    (null,loan_id2,7,cast(current_date+interval '6 month' as date),false),
    (null,loan_id2,8,cast(current_date+interval '7 month' as date),false),
    (null,loan_id2,9,cast(current_date+interval '8 month' as date),false),
    (null,loan_id2,10,cast(current_date+interval '9 month' as date),false),
    (null,loan_id2,11,cast(current_date+interval '10 month' as date),false),
    (null,loan_id2,12,cast(current_date+interval '11 month' as date),false);
    else return false;
    end if;
    return true;
    commit;
end;
$$;
-- call get_loan('123456789')
-- call get_loan('111111111')
-- call get_loan('999000111')
-- 
-- select * from loans
-- select * from accounts
--select * from transactions 
-- select * from payments_of_loan order by loan_id ,part
-- 

create or replace function loans_of_user(u_id integer)
RETURNS TABLE (
    usr_id integer,
    loan_id integer,
    accounts varchar(20),
    amnt decimal(10,2)
)
as
$$
begin
    return query
        select user_id, id as loanID, account, loan_amount
        from loans
        where user_id = u_id;
end;
$$language plpgsql;

-- select * from loans_of_user(1)
-- 

CREATE OR REPLACE FUNCTION pay_loan(loanId integer) 
RETURNS void
LANGUAGE plpgsql
AS 
$$
DECLARE 
    p_loan integer;
    amnt decimal(10,2);
    balance decimal(10,2);
    acc varchar(20);
BEGIN
    SELECT min(part) INTO p_loan 
    FROM payments_of_loan 
    WHERE loan_id = loanId AND bolean_paid = false;
    
    SELECT a.ammount INTO balance 
    FROM accounts AS a, loans AS l
    WHERE a.user_id = l.user_id AND l.id = loanId;
    
    SELECT a.account_number INTO acc 
    FROM accounts AS a, loans AS l
    WHERE a.user_id = l.user_id AND l.id = loanId;
      
    SELECT loan_amount INTO amnt 
    FROM loans 
    WHERE id = loanId;
    
    amnt := amnt * 1.2;
    amnt := amnt / 12;
 
    RAISE NOTICE '%', amnt;
    
    IF p_loan <= 12 AND balance > amnt THEN 
        UPDATE accounts 
        SET ammount = ammount - amnt
        WHERE account_number = acc;
        
        UPDATE payments_of_loan 
        SET payment_amount = amnt, bolean_paid = true
        WHERE part = p_loan AND loan_id = loanId;
    END IF;
END;
$$;

call pay_loan(1);
select * from payments_of_loan order by part ,loan_id;

select * from accounts;
CREATE OR REPLACE FUNCTION list_payment(loanId integer)
RETURNS TABLE(
    payment_id integer,
    payment DECIMAL(10,2),
    id_loan INTEGER,
    part_loan INTEGER,
    date_payment TIMESTAMP,
    bol_paid BOOLEAN
)
AS
$$
BEGIN
    RETURN QUERY
    SELECT *
    FROM payments_of_loan
    WHERE loan_id = loanId;
END;
$$ LANGUAGE plpgsql;

-- drop function list_payment(loanId INTEGER)
select * from list_payment(9);


create or replace function last_payment(loanId integer) 
returns BOOLEAN
language plpgsql
AS 
$$
declare p_loan integer;
declare amnt decimal(10,2);
declare balance decimal(10,2);
declare acc varchar(20);
begin
    select min(part) into p_loan from payments_of_loan 
    where loan_id=loanId and bolean_paid=false;
    
    select loan_amount into amnt from loans where id=loanid;
    amnt=amnt*1.2;
    amnt=amnt/12;
    
    select ammount into balance from accounts as a,loans as l
    where a.user_id=l.user_id and l.id=loanId;
    
    select account_number into acc from accounts as a,loans as l
    where a.user_id=l.user_id and l.id=loanId;
    
    raise notice '%',amnt;
    
    if p_loan =12 and balance>amnt then 

    update accounts 
    set ammount=ammount-amnt
    where account_number=acc;
    
    update payments_of_loan 
    set  payment_amount=amnt , bolean_paid = true
    where part=p_loan and loan_id=loanid;
    return true;
    else return false;

    end if;
    
    commit;
end;
$$;

-- select last_payment(1)
-- 

