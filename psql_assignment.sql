--1. NUMBER OF PEOPLE USING WAVE:
SELECT count (u_id) FROM users; --#returns a count(number) of all the users in the users table

--2. NUMBER OF TRANSFERS SENT IN CFA CURRENCY:
SELECT count (transfer_id) 
FROM transfers 
WHERE send_amount_currency = 'CFA'; --#returns a count(number) of only transfers in CFA

--3. NUMBER OF USERS WHO SENT A TRANSFER IN CFA CURRENCY:
SELECT count (u_id) 
FROM transfers 
WHERE send_amount_currency = 'CFA'; --#returns a count(number) using the user id foreign key in transfers table

--4. NUMBER OF AGENT TRANSACTIONS IN 2018: 
SELECT count (atx_id) 
FROM agents 
WHERE extract(YEAR FROM when_created) = 2018 -- extract() pulls the year from the timestamp and checks for 2018
GROUP BY extract(MONTH FROM when_created); -- extract() groups the results by month.

--5. NUMBER OF AGENTS WHO WERE NET DEPOSITORS AND NET WITHDRAWERS IN THE PAST WEEK
SELECT 
sum(CASE WHEN amount>0 THEN amount ELSE 0 END) AS withdrawal, 
sum(CASE WHEN amount<0 THEN amount ELSE 0 END) AS deposit, 
CASE WHEN ((CASE WHEN amount>0 THEN amount ELSE 0 END) > (CASE WHEN amount<0 THEN amount ELSE 0 END) * -1) 
THEN 'withdrawer' ELSE 'depositer' END AS agent_status
FROM agent_transactions 
WHERE when_created >= NOW() - INTERVAL '1 week'
GROUP BY agent_transactions.amount;

--6. SUMMARY OF AGENT TRANSACTION VOLUME IN THE PAST WEEK, GROUPED BY CITY:
SELECT agents.city AS City, count(agent_transactions.atx_id) AS Volume 
INTO atx_volume_city_summary --#creates a new table and adds the city and volume to it by joining two tables
FROM agents INNER JOIN agent_transactions ON agents.agent_id = agent_transactions.agent_id 
WHERE agent_transactions.when_created >= NOW() - INTERVAL '1 week' --#checks one week interval
GROUP BY agents.city;
SELECT * FROM atx_volume_city_summary;

--7. SUMMARY OF AGENT TRANSACTION VOLUME IN THE PAST WEEK, GROUPED BY COUNTRY & CITY:
SELECT agents.country AS country, agents.city AS city, count(agent_transactions.atx_id) AS Volume 
INTO atx_volume_country_summary --#creates a new table and adds the country,city and volume to it by joining 2 tables.
FROM agents INNER JOIN agent_transactions ON agents.agent_id = agent_transactions.agent_id 
WHERE agent_transactions.when_created >= NOW() - INTERVAL '1 week' --#checks one week interval
GROUP BY agents.country, agents.city; 
SELECT * FROM atx_volume_country_summary;
	  
--8. TOTAL VOLUME OF TRANSFERS SENT IN THE PAST WEEK, GROUPED BY COUNTRY & TRANSFER KIND:
SELECT wallets.ledger_location AS country,transfers.kind AS transferkind, sum(transfers.send_amount_scalar) AS volume 
INTO send_volume_by_country_and_kind
FROM transfers INNER JOIN wallets ON transfers.source_wallet_id = wallets.wallet_id 
WHERE transfers.when_created >= NOW() - INTERVAL '1 week'
GROUP BY wallets.ledger_location, transfers.kind; 

SELECT * FROM send_volume_by_country_and_kind;

--9. TOTAL VOLUME OF TRANSFERS SENT IN THE PAST WEEK WITH UNIQUE SENDERS AND NO OF TRANSACTIONS, 
--   GROUPED BY COUNTRY & TRANSFER KIND:
SELECT wallets.ledger_location AS country, transfers.kind AS transfer_kind, sum (transfers.send_amount_scalar) AS volume, 
count (transfer_id) AS transaction_count, count (transfers.source_wallet_id) AS unique_senders
INTO send_volume_by_country_and_kind_2 --#creates a new table and adds the city and volume to it by joining two tables
FROM transfers INNER JOIN wallets ON transfers.source_wallet_id = wallets.wallet_id 
WHERE transfers.when_created >= NOW() - INTERVAL '1 week'
GROUP BY wallets.ledger_location, transfers.kind; 
SELECT * FROM send_volume_by_country_and_kind_2;

--10. WALLETS THAT SENT MORE THAN 10,000,000 CFA IN TRANSFERS IN THE LAST MONTH:
SELECT source_wallet_id AS wallet, send_amount_scalar AS sent_amount
FROM transfers 
WHERE send_amount_currency = 'CFA' AND send_amount_scalar > 10000000 AND 
when_created >= NOW() - interval '1 month'; --AND helps group all the conditions (currency, amount & interval)
