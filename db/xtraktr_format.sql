select
shape,common_id, common_name,
`Total Voter Turnout (#)` as 'Numerical Total Voter Turnout (#)',
case
  when `Total Voter Turnout (#)` = 0 then '0'
  when `Total Voter Turnout (#)` between 0 and 5000 then '0-5,000'
  when `Total Voter Turnout (#)` between 5000 and 10000 then '5,000-10,000'
  when `Total Voter Turnout (#)` between 10000 and 15000 then '10,000-15,000'
  when `Total Voter Turnout (#)` between 15000 and 20000 then '15,000-20,000'
  when `Total Voter Turnout (#)` between 20000 and 25000 then '20,000-25,000'
  when `Total Voter Turnout (#)` > 25000 then '> 25,000'
  else null
end as 'Categorical Total Voter Turnout (#)',

`Total Voter Turnout (%)` as `Numerical Total Voter Turnout (%)`,
case
  when `Total Voter Turnout (%)` between 0 and 5 then '0-5'
  when `Total Voter Turnout (%)` between 5 and 10 then '5-10'
  when `Total Voter Turnout (%)` between 10 and 15 then '10-15'
  when `Total Voter Turnout (%)` between 15 and 20 then '15-20'
  when `Total Voter Turnout (%)` between 20 and 30 then '20-30'
  when `Total Voter Turnout (%)` between 30 and 40 then '30-40'
  when `Total Voter Turnout (%)` between 40 and 50 then '40-50'
  when `Total Voter Turnout (%)` between 50 and 60 then '50-60'
  when `Total Voter Turnout (%)` between 60 and 70 then '60-70'
  when `Total Voter Turnout (%)` between 70 and 80 then '70-80'
  when `Total Voter Turnout (%)` between 80 and 90 then '80-90'
  when `Total Voter Turnout (%)` between 90 and 100 then '90-100'
  when `Total Voter Turnout (%)` > 100 then '> 100'
  else null
end as `Categorical Total Voter Turnout (%)`,

`Number of Precincts with Invalid Ballots > 5%` as 'Numerical Number of Precincts with Invalid Ballots > 5%',
case
  when `Number of Precincts with Invalid Ballots > 5%` between 0 and 2 then '0-2'
  when `Number of Precincts with Invalid Ballots > 5%` between 2 and 4 then '2-4'
  when `Number of Precincts with Invalid Ballots > 5%` between 4 and 6 then '4-6'
  when `Number of Precincts with Invalid Ballots > 5%` between 6 and 8 then '6-8'
  when `Number of Precincts with Invalid Ballots > 5%` between 8 and 10 then '8-10'
  when `Number of Precincts with Invalid Ballots > 5%` > 10 then '> 10'
  else null
end as 'Categorical Number of Precincts with Invalid Ballots > 5%',

case
  when `Giorgi Margvelashvili` > `Davit Bakradze` then 'Giorgi Margvelashvili'
  when `Davit Bakradze` > `Giorgi Margvelashvili` then 'Davit Bakradze'
  else null
end as 'Overall Results',

`Giorgi Margvelashvili` as `Numerical Giorgi Margvelashvili`,
case
  when `Giorgi Margvelashvili` between 0 and 5 then '0-5'
  when `Giorgi Margvelashvili` between 5 and 10 then '5-10'
  when `Giorgi Margvelashvili` between 10 and 15 then '10-15'
  when `Giorgi Margvelashvili` between 15 and 20 then '15-20'
  when `Giorgi Margvelashvili` between 20 and 30 then '20-30'
  when `Giorgi Margvelashvili` between 30 and 40 then '30-40'
  when `Giorgi Margvelashvili` between 40 and 50 then '40-50'
  when `Giorgi Margvelashvili` between 50 and 60 then '50-60'
  when `Giorgi Margvelashvili` between 60 and 70 then '60-70'
  when `Giorgi Margvelashvili` between 70 and 80 then '70-80'
  when `Giorgi Margvelashvili` between 80 and 90 then '80-90'
  when `Giorgi Margvelashvili` between 90 and 100 then '90-100'
  when `Giorgi Margvelashvili` > 100 then '> 100'
  else null
end as `Categorical Giorgi Margvelashvili`,

`Davit Bakradze` as `Numerical Davit Bakradze`,
case
  when `Davit Bakradze` between 0 and 5 then '0-5'
  when `Davit Bakradze` between 5 and 10 then '5-10'
  when `Davit Bakradze` between 10 and 15 then '10-15'
  when `Davit Bakradze` between 15 and 20 then '15-20'
  when `Davit Bakradze` between 20 and 30 then '20-30'
  when `Davit Bakradze` between 30 and 40 then '30-40'
  when `Davit Bakradze` between 40 and 50 then '40-50'
  when `Davit Bakradze` between 50 and 60 then '50-60'
  when `Davit Bakradze` between 60 and 70 then '60-70'
  when `Davit Bakradze` between 70 and 80 then '70-80'
  when `Davit Bakradze` between 80 and 90 then '80-90'
  when `Davit Bakradze` between 90 and 100 then '90-100'
  when `Davit Bakradze` > 100 then '> 100'
  else null
end as `Categorical Davit Bakradze`


from `2013 election pres - csv`
where common_id != '' and common_name != ''
and common_id != 999
and (shape = 'District' or shape = 'Tbilisi District')

