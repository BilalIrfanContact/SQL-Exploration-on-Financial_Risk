-- Skills Used: Aggregate Functions, Grouping, Ordering, Joins, Subqueries, 
--Temp Tables, Stored Procedures, CTEs, Data Analysis & Comparison

-- EXPLORATION ON "Personal Info" TABLE
select * from PersonalInfo


--Analyse age group distribution
select Age_Groups, count(Age_Groups) as No_of_People from PersonalInfo 
group by Age_Groups order by count(Age_Groups) desc



--Determine majority education level
select Education_Level, count(*) as No_of_People from PersonalInfo 
group by Education_Level order by count(*) desc



--Examine education-marital status relationship
select Education_Level, Marital_Status, count(*) as No_of_People from PersonalInfo 
group by Education_Level, Marital_Status order by Education_Level asc, Marital_Status asc



--Calculate average dependents per marital status
select Marital_Status, avg(Number_of_Dependents) as No_of_Dependents from PersonalInfo group by Marital_Status



--EXPLORATION ON "Financial Info" TABLE
select * from FinancialInfo



--Analyse credit score distribution
select 
	sum(case when credit_score between 600 and 650 then 1 else 0 end) as "CreditScore(600-650)",
	sum(case when credit_score between 651 and 700 then 1 else 0 end) as "CreditScore(651-700)",
	sum(case when credit_score between 701 and 750 then 1 else 0 end) as "CreditScore(701-750)",
	sum(case when credit_score between 751 and 799 then 1 else 0 end) as "CreditScore(751-799)"
from FinancialInfo



-- EXPLORATION ON BOTH TABLES
select * from PersonalInfo
select * from FinancialInfo



--Identify top 5 cities by loan amount and credit score
select top 5 City, avg(Loan_Amount) as Avg_Loan_Amounts, avg(Credit_Score) as Avg_Credit_Scores from PersonalInfo 
inner join FinancialInfo on PersonalInfo.PersonID = FinancialInfo.PersonID group by City order by Avg_Loan_Amounts desc



-- Determine average credit score by education level
select Education_Level, avg(Credit_Score) as Avg_CreditScores from PersonalInfo 
inner join FinancialInfo on PersonalInfo.PersonID = FinancialInfo.PersonID group by Education_Level order by Avg_CreditScores



-- Conduct comprehensive financial health analysis
select PersonID, Income, Credit_Score, Assets_Value, (Income * 0.3 + Credit_Score * 0.3 + Assets_Value * 0.3)/(Debt_to_Income_Ratio * 0.1 + 1) as CompositeScore 
into #CompositeScore from FinancialInfo



-- How composite score varies across different age groups, education levels, and employment statuses
select Age_Groups, avg(CompositeScore) as AvgCompositeScores from PersonalInfo inner join #CompositeScore 
on PersonalInfo.PersonID = #CompositeScore.PersonID group by Age_Groups order by AvgCompositeScores



select Education_Level, avg(CompositeScore) as AvgCompositeScores from PersonalInfo inner join #CompositeScore 
on PersonalInfo.PersonID = #CompositeScore.PersonID group by Education_Level order by AvgCompositeScores



select Employment_Status ,avg(CompositeScore) as AvgCompositeScores from FinancialInfo inner join #CompositeScore 
on FinancialInfo.PersonID = #CompositeScore.PersonID group by Employment_Status order by AvgCompositeScores



--A stored procedure for state risk rating distribution
create procedure DistributionOfRiskRating @State varchar(20)
as begin
select State, Risk_Rating , count(Risk_Rating) as RatingCount from PersonalInfo inner join FinancialInfo 
on PersonalInfo.PersonID = FinancialInfo.PersonID where State = @State group by State, Risk_Rating
end



--Identify high-risk individuals with above-average loans
select Age, Marital_Status, Number_of_Dependents from PersonalInfo inner join FinancialInfo on 
FinancialInfo.PersonID = PersonalInfo.PersonID where Loan_Amount > (select avg(Loan_Amount) from FinancialInfo) and Risk_Rating = 'High'



--Compare risk profiles: with vs. without dependents
select  
case
	when Number_of_Dependents > 0 then 'With Dependents'
	else 'Without Dependents'
end as DependentsStatus,
avg(Income)as AvgIncome, avg(Loan_Amount) as AvgLoan, avg(Credit_Score) as AvgCreditScore, Risk_Rating
from PersonalInfo inner join FinancialInfo on PersonalInfo.PersonID = FinancialInfo.FinancialID group by Risk_Rating, 
case
	when Number_of_Dependents > 0 then 'With Dependents'
	else 'Without Dependents'
end order by DependentsStatus



--Calculate average risk rating by education and gender
select Gender, Education_Level, avg(
case
	when Risk_Rating = 'high' then 3
	when Risk_Rating = 'meduim' then 2
	when Risk_Rating = 'low' then 1
end
) as AvgRiskRating  from PersonalInfo join FinancialInfo on 
PersonalInfo.PersonID = FinancialInfo.PersonID group by Gender, Education_Level order by Gender, Education_Level



--A CTE for risk tier categorization
with CTE_RiskTier as(
select PersonID, Risk_Rating, Credit_Score, Debt_to_Income_Ratio,
case 
	when Risk_Rating = 'High' or Credit_Score < 600 or Debt_to_Income_Ratio > 40 then 'High Risk' 
	when Risk_Rating = 'Medium' or Credit_Score < 650 or Debt_to_Income_Ratio > 30 then 'Medium Risk' 
	when Risk_Rating = 'Low' or Credit_Score < 700 or Debt_to_Income_Ratio > 20 then 'Low Risk' 
end  as RiskTier
from FinancialInfo
)

select personID, Risk_Rating, RiskTier from CTE_RiskTier	
