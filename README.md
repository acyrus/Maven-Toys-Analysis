# Maven Toys Analysis
Sales Analysis of the Maven Toys Chain Stores in Mexico.

# Overview
We have been provided with sales & inventory data for a fictitious chain of toy stores in Mexico called Maven Toys, 
including information about products, stores, daily sales transactions, and current inventory levels at each location. 

The data spans from January 1st 2017 to September 30th 2018, containing over 820,000 transactions for all stores owned by Maven Toys. 

The objective is to prepare the data, analyze and visualize it, and subsequently outline findings which allow the toy store chain to 
enhance its decision making capabilities and boost profits. 

The major questions that we will attempt to answer are:
1) Which product categories drive the biggest profits? Is this the same across store locations?
2) Are there any seasonal trends or patterns in the sales data?
3) Are sales being lost with out-of-stock products at certain locations?
4) How much money is tied up in inventory at the toy stores? How long will it last?

# Data Colletion
The data used within this project is provided from the following link:  
[Maven Toys Sales | Kaggle](https://www.kaggle.com/datasets/mysarahmadbhat/toy-sales)

# Data Preparation

We are provided with four CSV files which contain the following fields:

### Products:
1) Product_ID - Unique ID given to each product offered  
2) Product_Name - Unique name given to each product offered  
3) Product_Category - Category group assigned to each product based on its characteristics/utility  
4) Product_Cost - Expense incurred for making/attaining the product, in US dollars  
5) Product_Price - Price at which the product is sold to customers, in US dollars   

### Stores:
1) Store_ID - Unique store ID given to each toy store  
2) Store_Name - Unique store name given to each toy store  
3) Store_City - City in Mexico where the store is located  
4) Store_Location - Classification of location in the city where the store is located (Downtown,   
  Commercial, Residential, Airport)  
5) Store_Open_Date - Date when the store was opened  

### Sales:
1) Sale_ID - Unique Sale_ID for each transaction conducted in a store  
2) Date - Date on which the transaction occurred  
3) Store_ID - Unique store ID given to each toy store  
4) Product_ID - Unique ID given to each product offered  
5) Units - No of units of the product sold  
 
### Inventory:
1) Store_ID - Unique store ID given to each toy store  
2) Product_ID - Unique ID given to each product offered  
3) Stock_On_Hand - Stock quantity of the product in the store  
 
# Data Preparation:
Given the nature of the information provided, it is beneficial to place it into a MySQL database. 
The data has been separated into multiple tables that can be linked to each other based on identical fields. 
Queries provide for quick and easy manipulation of data and access to database insights. 
The usage of a database also guarantees a level of data integrity based on the enforced data types within our tables. 
Establishing constraints such as primary and foreign keys also allows us to avoid incorrect values and duplicated data which 
gives us confidence that the data we are using is accurate.   

### Data Model
![MavenToys Database Schema](https://user-images.githubusercontent.com/45236211/205615304-81c3d805-5bdc-4004-81a5-be2990bf2d0f.PNG)

### SQL Database Schema Creation
[MavenToys Database Creation](https://github.com/acyrus/Maven-Toys-Analysis/blob/main/Database%20Schema%20Creation.sql)

### Importing Data Into CSV Files
[CSV File Import](https://github.com/acyrus/Maven-Toys-Analysis/blob/main/Data%20Import%20from%20CSV%20Files.sql)

The data provided is fairly simple and easy to understand. After double checking imports and comparing it to source data, we are confident 
that the data has been imported successfully and accurately. 



# Data Analysis
Exploratory Data Analysis techniques in MySQL will be used to analyze the prepared dataset. This will allow us to produce descriptive statistics
which helps to understand patterns, detect outliers and find interesting relations among the variables. We will utilize various SQL elements such
as Aggregate Functions, Joins, Temporary Tables, CTEs, Stored Procedures and Window Functions. 




