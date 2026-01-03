-- 1. DASHBOARD 1: SUMMARY
-- 1.1. KPIs
-- 1.1.1. Total/Average
SELECT
        COUNT(id) AS Total_Applications,
        SUM(loan_amount) AS Total_Funded_Amount,
		SUM(total_payment) AS Total_Amount_Received,
        AVG(int_rate) AS Avg_Interest_Rate,
        AVG(dti) AS Avg_DTI
FROM financial_loan;
-- 1.1.2. MTD, MoM
WITH Monthly_Stats AS (
    SELECT
        DATE_FORMAT(STR_TO_DATE(issue_date, '%d-%m-%Y'), '%Y-%m') AS Month_Year,
        COUNT(id) AS Total_Applications,
        SUM(loan_amount) AS Total_Funded_Amount,
		SUM(total_payment) AS Total_Amount_Received,
        AVG(int_rate) AS Avg_Interest_Rate,
        AVG(dti) AS Avg_DTI
    FROM financial_loan
    GROUP BY Month_Year),
Prev_Stats AS (
    SELECT
        Month_Year, 
        Total_Applications, LAG(Total_Applications, 1, 0) OVER (ORDER BY Month_Year) AS Prev_Total_Applications,
        Total_Funded_Amount, LAG(Total_Funded_Amount, 1, 0) OVER (ORDER BY Month_Year) AS Prev_Total_Funded_Amount,
		Total_Amount_Received, LAG(Total_Amount_Received, 1, 0) OVER (ORDER BY Month_Year) AS Prev_Amount_Received,
        Avg_Interest_Rate, LAG(Avg_Interest_Rate, 1, 0) OVER (ORDER BY Month_Year) AS Prev_Avg_Interest_Rate,
        Avg_DTI, LAG(Avg_DTI, 1, 0) OVER (ORDER BY Month_Year) AS Prev_Avg_DTI
    FROM Monthly_Stats)
SELECT
    Month_Year,
	Total_Applications as MTD_Applications, (Total_Applications - Prev_Total_Applications) / NULLIF(Prev_Total_Applications, 0) AS MoM_Applications,
    Total_Funded_Amount as MTD_Funded_Amount, (Total_Funded_Amount - Prev_Total_Funded_Amount) / NULLIF(Prev_Total_Funded_Amount, 0) AS MoM_Funded_Amount,
	Total_Amount_Received as MTD_Amount_Received, (Total_Amount_Received - Prev_Amount_Received) / NULLIF(Prev_Amount_Received, 0) AS MoM_Amount_Received,
    Avg_Interest_Rate as MTD_Interest_Rate, (Avg_Interest_Rate - Prev_Avg_Interest_Rate) / NULLIF(Prev_Avg_Interest_Rate, 0) AS MoM_Interest_Rate,
	Avg_DTI as MTD_DTI, (Avg_DTI - Prev_Avg_DTI) / NULLIF(Prev_Avg_DTI, 0) AS MoM_DTI
FROM Prev_Stats
ORDER BY Month_Year;
-- 1.2. Good Loan vs Bad Loan
SELECT
    CASE WHEN loan_status IN ('Fully Paid', 'Current') THEN 'Good Loan'
         WHEN loan_status = 'Charged Off' THEN 'Bad Loan'
    END AS Loan_Category,
    COUNT(id) AS Total_Applications,
    (COUNT(id) / (SELECT COUNT(id) FROM financial_loan)) AS Percentage_of_Total_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM financial_loan
GROUP BY Loan_Category;
-- 1.3. Loan Status Grid View
SELECT
    loan_status,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(CASE 
        WHEN MONTH(STR_TO_DATE(issue_date, '%d-%m-%Y')) = (SELECT MONTH(MAX(STR_TO_DATE(issue_date, '%d-%m-%Y'))) FROM financial_loan)
         AND YEAR(STR_TO_DATE(issue_date, '%d-%m-%Y')) = (SELECT YEAR(MAX(STR_TO_DATE(issue_date, '%d-%m-%Y'))) FROM financial_loan) 
        THEN loan_amount ELSE 0 END) AS MTD_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received,
    SUM(CASE 
        WHEN MONTH(STR_TO_DATE(issue_date, '%d-%m-%Y')) = (SELECT MONTH(MAX(STR_TO_DATE(issue_date, '%d-%m-%Y'))) FROM financial_loan) 
         AND YEAR(STR_TO_DATE(issue_date, '%d-%m-%Y')) = (SELECT YEAR(MAX(STR_TO_DATE(issue_date, '%d-%m-%Y'))) FROM financial_loan) 
        THEN total_payment ELSE 0 END) AS MTD_Amount_Received,
    AVG(int_rate) AS Avg_Interest_Rate,
    AVG(dti) AS Avg_DTI
FROM financial_loan
GROUP BY loan_status;
-- 2. DASHBOARD 2: OVERVIEW
-- 2.1. Monthly Trends by Issue Date
SELECT
    DATE_FORMAT(STR_TO_DATE(issue_date, '%d-%m-%Y'), '%Y-%m') AS Month_Year,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM financial_loan
GROUP BY Month_Year
ORDER BY Month_Year;
-- 2.2.2. Regional Analysis by State
SELECT
    address_state,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM financial_loan
GROUP BY address_state
ORDER BY Total_Funded_Amount DESC;
-- 2.2.3. Loan Term Analysis
SELECT
    term,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM financial_loan
GROUP BY term;
-- 2.2.4. Employee Length Analysis
SELECT
    emp_length,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM financial_loan
GROUP BY emp_length
ORDER BY Total_Loan_Applications DESC;
-- 2.2.5. Loan Purpose Breakdown
SELECT
    purpose,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM financial_loan
GROUP BY purpose
ORDER BY Total_Loan_Applications DESC;
-- 2.2.6. Home Ownership Analysis
SELECT
    home_ownership,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM financial_loan
GROUP BY home_ownership
ORDER BY Total_Loan_Applications DESC;