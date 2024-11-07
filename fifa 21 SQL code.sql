/* TASK TO PERFORM
1. convert k to 000 in HIT column
2. split W/F, SM and IR, by removing the symbols from the numbers
3. remove symbols from amount in WAGE, VALUE and RELEASE column
4. replace JOINED column with CONTRACT start year, and LOAN DATE END with CONTRACT end year
5. change height and weight to cm and kg respectively
6. correct club name and remove extra space
7. use PLAYER URL column to input NAME column
8. delete irrelevant columns
9. change column names
*/

USE setadata;

-- explore the data
SELECT * 
FROM setadata.dbo.fifa21;

-- cout pf columns
SELECT COUNT(column_name)
FROM information_schema.columns
WHERE table_name = 'fifa21';

--check column information
EXEC sp_help fifa21;


-- check for duplicates

--to identify the number of duplicate values
SELECT longname, age, nationality, club, COUNT(*)
FROM setadata.dbo.fifa21
GROUP BY longname, age, nationality, club
HAVING COUNT(*)>1;

-- to confirm the other informations for peng wang
SELECT *
FROM setadata.dbo.fifa21
WHERE longname = 'peng wang';

-- no duplicate, they are both different players in same club


/* 1. convert k to 000 in HIT column
a. explore the hit column
b. extract the digit from the 'k'
c. convert the data type from string to float, and multiply by 1000, and convert back to string
d. update HITS column
e. change HITS column datatype
f. replace 'NULL' with 0
g. update column
*/

SELECT hits
FROM setadata.dbo.fifa21;

-- select values with k
SELECT hits
FROM setadata.dbo.fifa21
WHERE hits LIKE '%k';

-- extract k from the values
SELECT SUBSTRING(hits, 1, CHARINDEX('K', hits)-1) hit_extract
FROM setadata.dbo.fifa21
WHERE hits LIKE '%k';

-- convert to float datatype and multiply by 1000
SELECT CAST((CAST(SUBSTRING(hits, 1, CHARINDEX('K', hits)-1) AS FLOAT) *1000) AS nvarchar)
FROM setadata.dbo.fifa21
WHERE hits LIKE '%k';

-- update the column with the new values
UPDATE setadata.dbo.fifa21
SET hits = CAST((CAST(SUBSTRING(hits, 1, CHARINDEX('K', hits)-1) AS FLOAT) *1000) AS nvarchar)
WHERE hits LIKE '%k';

-- convert the dataype to integer
ALTER TABLE setadata.dbo.fifa21
ALTER COLUMN hits int;

-- handling missing values by replacing null with 0
UPDATE setadata.dbo.fifa21
SET Hits = COALESCE(hits,0)
WHERE hits IS NULL;


/* 2. split W/F, SM and IR, by removing the symbols from the numbers
a. explore W/F, SM, and IR coclumn
b. etract the digits from symbols
c. update the columns
d. change datatype to int
*/

SELECT [W/F], SM, IR
FROM setadata.dbo.fifa21;

-- extract the digit
SELECT SUBSTRING([W/F],1,1), SUBSTRING(SM,1,1),SUBSTRING(IR,1,1)
FROM setadata.dbo.fifa21;

-- update W/F column with the numbers
UPDATE setadata.dbo.fifa21
SET [W/F] = SUBSTRING([W/F],1,1);

--update SM colum with the number extracted
UPDATE setadata.dbo.fifa21
SET SM = SUBSTRING(SM,1,1);

--update IR column with the number extracted
UPDATE setadata.dbo.fifa21
SET IR = SUBSTRING(IR,1,1);


-- change the datatype from string to int on all 3 columns
ALTER TABLE setadata.dbo.fifa21
ALTER COLUMN [W/F] int;

ALTER TABLE setadata.dbo.fifa21
ALTER COLUMN SM int;

ALTER TABLE setadata.dbo.fifa21
ALTER COLUMN IR int;


/* 3. remove symbols from amount in WAGE, VALUE and RELEASE column
a. explore the columns
b. remove the symbols, and letters
c. convert the k to 000, and m to 000,000
d. update the columns
e. change datatype
*/

SELECT wage, value, [release clause]
FROM setadata.dbo.fifa21;

-- extracting the symbols from the column
SELECT SUBSTRING(wage,4, LEN(wage)) wg, SUBSTRING(value,4, LEN(value)) vl, SUBSTRING([release clause],4, LEN([release clause])) rc
FROM setadata.dbo.fifa21;

--for wage
SELECT DISTINCT SUBSTRING(wage,4, LEN(wage)) wg
FROM setadata.dbo.fifa21;

-- extracting the letters from the numbers and conerting the letters to their equivalent 
SELECT SUBSTRING(SUBSTRING(wage,4, LEN(wage)),1, LEN(SUBSTRING(wage,4, LEN(wage)))-1), 
		CASE 
			WHEN SUBSTRING(wage,4, LEN(wage)) LIKE '%K' THEN '1000'
			ELSE '1'
		END AS kilo
FROM setadata.dbo.fifa21;

-- creating a column to contain K equivalent, which is 1000
ALTER TABLE setadata.dbo.fifa21
ADD wage_multiplier int;

-- update the wage multiplier column with 
UPDATE setadata.dbo.fifa21
SET wage_multiplier = CASE 
			WHEN SUBSTRING(wage,4, LEN(wage)) LIKE '%K' THEN '1000'
			ELSE '1'
		END;

SELECT CAST(SUBSTRING(SUBSTRING(wage,4, LEN(wage)),1, LEN(SUBSTRING(wage,4, LEN(wage)))-1) AS int) * wage_multiplier
FROM setadata.dbo.fifa21;

-- convert wage to int and multiply with wage_multiplier
UPDATE setadata.dbo.fifa21
SET wage = CAST(SUBSTRING(SUBSTRING(wage,4, LEN(wage)),1, LEN(SUBSTRING(wage,4, LEN(wage)))-1) AS int) * wage_multiplier

-- change the column datatype to int
ALTER TABLE setadata.dbo.fifa21
ALTER COLUMN wage int;

--for value
SELECT DISTINCT SUBSTRING(value,4, LEN(value)) vl
FROM setadata.dbo.fifa21;

SELECT SUBSTRING(SUBSTRING(value,4, LEN(value)),1, LEN(SUBSTRING(value,4, LEN(value)))-1), 
		CASE 
			WHEN SUBSTRING(value,4, LEN(value)) LIKE '%M' THEN '1000000'
			WHEN SUBSTRING(value,4, LEN(value)) LIKE '%K' THEN '1000'
			ELSE '1'
		END AS milli
FROM setadata.dbo.fifa21;

ALTER TABLE setadata.dbo.fifa21
ADD value_multiplier int;

UPDATE setadata.dbo.fifa21
SET value_multiplier = CASE 
			WHEN SUBSTRING(value,4, LEN(value)) LIKE '%M' THEN '1000000'
			WHEN SUBSTRING(value,4, LEN(value)) LIKE '%K' THEN '1000'
			ELSE '1'
		END;

SELECT CAST(SUBSTRING(SUBSTRING(value,4, LEN(value)),1, LEN(SUBSTRING(value,4, LEN(value)))-1) AS float) * value_multiplier
FROM setadata.dbo.fifa21;

UPDATE setadata.dbo.fifa21
SET value = CAST(SUBSTRING(SUBSTRING(value,4, LEN(value)),1, LEN(SUBSTRING(value,4, LEN(value)))-1) AS float) * value_multiplier

ALTER TABLE setadata.dbo.fifa21
ALTER COLUMN value float;

ALTER TABLE setadata.dbo.fifa21
ALTER COLUMN value int;

--for release clause
SELECT  SUBSTRING([release clause],4, LEN([release clause])) rc
FROM setadata.dbo.fifa21;

SELECT SUBSTRING(SUBSTRING([release clause],4, LEN([release clause])),1, LEN(SUBSTRING([release clause],4, LEN([release clause])))-1), 
		CASE 
			WHEN SUBSTRING([release clause],4, LEN([release clause])) LIKE '%M' THEN '1000000'
			WHEN SUBSTRING([release clause],4, LEN([release clause])) LIKE '%K' THEN '1000'
			ELSE '1'
		END AS milli
FROM setadata.dbo.fifa21;

ALTER TABLE setadata.dbo.fifa21
ADD rc_multiplier int;

UPDATE setadata.dbo.fifa21
SET rc_multiplier = CASE 
			WHEN SUBSTRING([release clause],4, LEN([release clause])) LIKE '%M' THEN '1000000'
			WHEN SUBSTRING([release clause],4, LEN([release clause])) LIKE '%K' THEN '1000'
			ELSE '1'
		END;

SELECT CAST(SUBSTRING(SUBSTRING([release clause],4, LEN([release clause])),1, LEN(SUBSTRING([release clause],4, LEN([release clause])))-1) AS float) * rc_multiplier
FROM setadata.dbo.fifa21;

UPDATE setadata.dbo.fifa21
SET [release clause] = CAST(SUBSTRING(SUBSTRING([release clause],4, LEN([release clause])),1, LEN(SUBSTRING([release clause],4, LEN([release clause])))-1) AS float) * rc_multiplier

ALTER TABLE setadata.dbo.fifa21
ALTER COLUMN [release clause] float;

ALTER TABLE setadata.dbo.fifa21
ALTER COLUMN [release clause] int;


/* 4. change JOINED column datatype to date, and replace LOAN DATE END with CONTRACT end year, change column name
a. explore joined, contract, and loan date column
b. change joined datatype to date
c. extract the end date from contract column
d. update the end date to loan date end
*/

SELECT DISTINCT joined, [loan date end], contract
FROM setadata.dbo.fifa21;

SELECT DISTINCT [loan date end], contract
FROM setadata.dbo.fifa21;

-- changed joined datatype to date
ALTER TABLE setadata.dbo.fifa21
ALTER COLUMN joined date;

-- take out the start year, and leave the end year from contract
SELECT contract,
		CASE 
			WHEN contract LIKE '%~%' THEN SUBSTRING(contract,8, LEN(contract))
			WHEN contract LIKE '%on%' THEN 'On Loan'
			ELSE 'Free'
		END AS Contract_end	
FROM setadata.dbo.fifa21;

-- update the contract column
UPDATE setadata.dbo.fifa21
SET contract = CASE 
			WHEN contract LIKE '%~%' THEN SUBSTRING(contract,8, LEN(contract))
			WHEN contract LIKE '%on%' THEN 'On Loan'
			ELSE 'Free'
		END; 

-- replace null value with not on loan'
SELECT CASE
			WHEN [loan date end] LIKE '%-%' THEN [loan date end]
			ELSE 'Not On Loan'
			END
FROM setadata.dbo.fifa21;

-- update the loan date end column
UPDATE setadata.dbo.fifa21
SET [loan date end] = CASE
			WHEN [loan date end] LIKE '%-%' THEN [loan date end]
			ELSE 'Not On Loan'
			END;


/* 5. change height and weight to cm and kg respectively
a. explore height and weight column
b. extract numbers from letter and symbols in both columns
c. convert feet to inches , then to cm in the height column. (inch = ft * 12, cm = inch * 2.54)
d. convert lbs to kg in the weight column. (kg = lbs/2.205)
*/
SELECT height, weight 
FROM setadata.dbo.fifa21;

SELECT DISTINCT height, weight
FROM setadata.dbo.fifa21;

SELECT weight
FROM setadata.dbo.fifa21;

-- for weight, extract the measures, then divide lbs by 2.205
SELECT weight, ROUND(CAST(SUBSTRING(weight, 1, CHARINDEX('l', weight)-1) AS float)/2.205,0)
FROM setadata.dbo.fifa21
WHERE weight LIKE '%l%';

-- remove the kg form the value in weight 
SELECT weight, CAST(SUBSTRING(weight, 1, CHARINDEX('k', weight)-1) AS float)
FROM setadata.dbo.fifa21
WHERE weight LIKE '%k%';

-- update the values with kg
UPDATE setadata.dbo.fifa21
SET weight = SUBSTRING(weight, 1, CHARINDEX('k', weight)-1)
WHERE weight LIKE '%k%';

-- update the values 
UPDATE setadata.dbo.fifa21
SET weight = ROUND(CAST(SUBSTRING(weight, 1, CHARINDEX('l', weight)-1) AS float)/2.205, 0)
WHERE weight LIKE '%l%';

-- change datatype to int
ALTER TABLE setadata.dbo.fifa21
ALTER COLUMN weight int;

-- for height, convert feet to inches , then to cm in the height column. (inch = ft * 12, cm = inch * 2.54)
SELECT height, ROUND(((LEFT(height, 1)*12)+(SUBSTRING(height, 3, CHARINDEX('"', height)-3)))*2.54,0) AS cm
FROM setadata.dbo.fifa21
WHERE height LIKE '%"';

-- extract the cm from the height column
SELECT SUBSTRING(height, 1, LEN(height)-2)
FROM setadata.dbo.fifa21
WHERE height LIKE '%cm';

-- update the column with the cconversion
UPDATE setadata.dbo.fifa21
SET height = ROUND(((LEFT(height, 1)*12)+(SUBSTRING(height, 3, CHARINDEX('"', height)-3)))*2.54,0)
WHERE height LIKE '%"';

-- update the column with teh extracted values
UPDATE setadata.dbo.fifa21
SET height = SUBSTRING(height, 1, LEN(height)-2)
WHERE height LIKE '%cm';

-- change the datatype to int
ALTER TABLE setadata.dbo.fifa21
ALTER COLUMN height int;


/* 6. correct club name and remove extra space
a. explore the club column
b. remove the xtra 4 spaces in front of the club column
c. group the club by name
d. use google to manually find real name of club
e. replace the real names with the symbolized names
f. update column
*/

SELECT club
FROM setadata.dbo.fifa21;


-- group by club name
SELECT club, COUNT(club)
FROM setadata.dbo.fifa21
GROUP BY club
ORDER BY club;

--remove the extra space in the club column
UPDATE setadata.dbo.fifa21
SET club = SUBSTRING(club, 5, LEN(club))
WHERE club != 'No Club';

-- replacing the symbols with letters
UPDATE setadata.dbo.fifa21
SET club = 'Liverpool Football Club'
WHERE club = 'Liverpool Fútbol Club';

UPDATE setadata.dbo.fifa21
SET club = 'Club Leon'
WHERE club = 'Club León';

UPDATE setadata.dbo.fifa21
SET club = '1. FC Koln'
WHERE club = '1. FC Köln';

UPDATE setadata.dbo.fifa21
SET club = '1. FC Nurnberg'
WHERE club = '1. FC Nürnberg';

UPDATE setadata.dbo.fifa21
SET club = '1. FC Nurnberg'
WHERE club = '1. FC Nürnberg';

UPDATE setadata.dbo.fifa21
SET club = '1. FC Saarbrucken'
WHERE club = '1. FC Saarbrücken';

UPDATE setadata.dbo.fifa21
SET club = 'Caykur Rizespor'
WHERE club = 'Ã‡aykur Rizespor';

UPDATE setadata.dbo.fifa21
SET club = 'AD Alcorcon'
WHERE club = 'AD Alcorcón';

UPDATE setadata.dbo.fifa21
SET club = 'America de Cali'
WHERE club = 'América de Cali';

UPDATE setadata.dbo.fifa21
SET club = 'Orebro SK'
WHERE club = 'Ã–rebro SK';

UPDATE setadata.dbo.fifa21
SET club = 'Arsenal de Sarandi'
WHERE club = 'Arsenal de SarandÃ­';

UPDATE setadata.dbo.fifa21
SET club = 'Arsenal de Sarandi'
WHERE club = 'Arsenal de SarandÃ­';

UPDATE setadata.dbo.fifa21
SET club = 'Arsenal de Sarandi'
WHERE club = 'Arsenal de SarandÃ­';

UPDATE setadata.dbo.fifa21
SET club = 'AS Saint-Etienne'
WHERE club = 'AS Saint-Ã‰tienne';

UPDATE setadata.dbo.fifa21
SET club = 'Slask Wroclaw'
WHERE club = 'ÅšlÄ…sk Wroclaw';

UPDATE setadata.dbo.fifa21
SET club = 'Ostersunds FK'
WHERE club = 'Ã–stersunds FK';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ã©', 'e')
WHERE club LIKE '%AtlÃ©tico%';

UPDATE setadata.dbo.fifa21
SET club = 'Atletico Tucuman'
WHERE club = 'Atletico TucumÃ¡n';

UPDATE setadata.dbo.fifa21
SET club = 'Bayern Munchen II'
WHERE club = 'Bayern Munich II';

UPDATE setadata.dbo.fifa21
SET club = 'Besiktas JK'
WHERE club = 'BeÅŸiktaÅŸ JK';

UPDATE setadata.dbo.fifa21
SET club = 'BK Hacken'
WHERE club = 'BK HÃ¤cken';

UPDATE setadata.dbo.fifa21
SET club = 'Borussia Monchengladbach'
WHERE club = 'Borussia MÃ¶nchengladbach';

UPDATE setadata.dbo.fifa21
SET club = 'Brondby IF'
WHERE club = 'BrÃ¸ndby IF';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ã©', 'e')
WHERE club LIKE '%Ã©%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ã', 'i')
WHERE club LIKE '%Ã­%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'i­', 'i')
WHERE club LIKE '%i­%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ã³', 'o')
WHERE club LIKE '%Ã³%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ã¡', 'a')
WHERE club LIKE '%Ã¡%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ã¢', 'a')
WHERE club LIKE '%Ã¢%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'ÅŸ', 's')
WHERE club LIKE '%ÅŸ%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ãº', 'u')
WHERE club LIKE '%Ãº%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ã£', 'a')
WHERE club LIKE '%Ã£%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ã¥', 'a')
WHERE club LIKE '%Ã¥%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ã¼', 'u')
WHERE club LIKE '%Ã¼%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ã¶', 'o')
WHERE club LIKE '%Ã¶%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ã¸', 'o')
WHERE club LIKE '%Ã¸%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ã§', 'c')
WHERE club LIKE '%Ã§%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ã±', 'n')
WHERE club LIKE '%Ã±%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ãª', 'e')
WHERE club LIKE '%Ãª%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ã¨', 'e')
WHERE club LIKE '%Ã¨%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Å‚', 'l')
WHERE club LIKE '%Å‚%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Å„', 'n')
WHERE club LIKE '%Å„%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'ÄŸ', 'g')
WHERE club LIKE '%ÄŸ%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ä™', 'e')
WHERE club LIKE '%Ä™%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ã¦', 'ae')
WHERE club LIKE '%Ã¦%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Åˆ', 'n')
WHERE club LIKE '%Åˆ%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ã¤', 'a')
WHERE club LIKE '%Ã¤%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'Ã®', 'i')
WHERE club LIKE '%Ã®%';

UPDATE setadata.dbo.fifa21
SET club = REPLACE(club, 'È™', 's')
WHERE club LIKE '%È™%';



/* 7. replace long name with names listed in player url
a. explore the player url
b. extract the name from the url
c. replace - with spaces
d. change letters to uppercase
e. update the longname column*/

SELECT longname
FROM setadata.dbo.fifa21;

SELECT playerUrl, SUBSTRING(SUBSTRING(playerurl, CHARINDEX('r/',playerurl)+2, LEN(playerurl)), 
				CHARINDEX('/', SUBSTRING(playerurl, CHARINDEX('r/',playerurl)+2, LEN(playerurl)))+1, 
				LEN(SUBSTRING(playerurl, CHARINDEX('r/',playerurl)+2, LEN(playerurl))))
FROM setadata.dbo.fifa21;

-- creating a temp column to store the first extraction
ALTER TABLE setadata.dbo.fifa21
ADD playerweb2 nvarchar(255);

-- updating the new column with the partial extraction
UPDATE setadata.dbo.fifa21
SET playerweb2 = SUBSTRING(SUBSTRING(playerurl, CHARINDEX('r/',playerurl)+2, LEN(playerurl)), 
				CHARINDEX('/', SUBSTRING(playerurl, CHARINDEX('r/',playerurl)+2, LEN(playerurl)))+1, 
				LEN(SUBSTRING(playerurl, CHARINDEX('r/',playerurl)+2, LEN(playerurl))));

SELECT SUBSTRING(playerweb2, 1, CHARINDEX('/2', playerweb2)-1) 
FROM setadata.dbo.fifa21;

-- updating column with the names
UPDATE setadata.dbo.fifa21
SET playerweb2 = SUBSTRING(playerweb2, 1, CHARINDEX('/2', playerweb2)-1);

SELECT playerweb2, UPPER(REPLACE(playerweb2, '-', ' '))
FROM setadata.dbo.fifa21
WHERE playerweb2 LIKE '%-%';

-- update longname with playerweb, replace '-' with space, and change to upper case
UPDATE setadata.dbo.fifa21
SET LongName = UPPER(REPLACE(playerweb2, '-', ' '));


/* 8. delete irrelevant columns*/

ALTER TABLE setadata.dbo.fifa21
DROP COLUMN name, 
			photourl,
			playerurl,
			positions,
			wage_multiplier, 
			value_multiplier, 
			rc_multiplier, 
			playerweb2;

/* 9. change column name*/

EXEC sp_rename 'fifa21.longname', 'Name';
EXEC sp_rename 'fifa21.â†“OVA', 'OVA';
EXEC sp_rename 'fifa21.Value', 'Value(€)';
EXEC sp_rename 'fifa21.Wage', 'Wage(€)';
EXEC sp_rename 'fifa21.[Release Clause]', 'Release Clause(€)';
EXEC sp_rename 'fifa21.height', 'Height(cm)';
EXEC sp_rename 'fifa21.weight', 'Weight(kg)';
EXEC sp_rename 'fifa21.[Loan Date End]', 'Loan Date';
EXEC sp_rename 'fifa21.contract', 'Contract End Year';
EXEC sp_rename 'fifa21.Joined', 'Joined Date';