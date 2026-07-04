# Supply Chain Analytics: Vessel Performance Analytics
### Case Study: Vessel Operations between Helsinki (FIHEL) and Tallinn (EETLL)

---

## Project Overview

This project analyzes vessel operational performance using Automatic Identification System (AIS) data collected from passenger vessels operating between **Helsinki (FIHEL)** and **Tallinn (EETLL)**. The objective is to evaluate departure and arrival performance, assess data quality, and develop operational KPIs through SQL-based data cleaning and Power BI visualization.

The analysis covers more than **824,000 voyage records** from four vessels: **Europa, Finlandia, Megastar, and Star**.

---

# Business Problem

Reliable vessel performance metrics are essential for monitoring operational efficiency and supporting logistics planning. However, the raw AIS dataset contained inconsistent timestamps, duplicate records, and incomplete arrival information, producing unrealistic delay calculations that could lead to incorrect business decisions.

The project focuses on:

* Measuring departure and arrival performance
* Evaluating data completeness
* Identifying operational trends across vessels
* Producing reliable KPIs through data cleaning and validation

---

# Dataset

**Source**

* Kaggle – Container ship data collection

**Dataset Size**

* 824,000+ voyage records

**Route**

* Helsinki (FIHEL)
* Tallinn (EETLL)

**Vessels**

* Europa
* Finlandia
* Megastar
* Star

---

# Data Cleaning

Several data quality issues were identified before analysis.

### Problems Found

* Mixed date formats
* Duplicate records
* Missing arrival timestamps
* Estimated and actual timestamps belonging to different voyages
* Unrealistic departure delays (average = **-30.57 hours**)

### Cleaning Process

* Standardized inconsistent date and time formats using SQLite
* Removed duplicate records
* Validated timestamp consistency
* Applied business rules in DAX to retain only realistic departure delays between **-2 and +24 hours**
* Preserved the original dataset of more than **824K voyage records** while calculating filtered performance metrics.

---

# Methodology

The project followed a structured analytics workflow:

1. Data exploration
2. Data cleaning using SQLite
3. KPI calculation using DAX
4. Dashboard development in Power BI
5. Performance comparison across vessels
6. Business insight generation

---

# Dashboard

The Power BI dashboard includes:

### Operational KPIs

* Total Voyages
* Average Departure Delay
* On-Time Departure Rate
* On-Time Arrival Rate
* Data Completeness

### Visualizations

* Vessel comparison
* Departure delay trends
* Arrival performance
* Missing data analysis
* Operational KPI summary

---

# Key Insights

### Data Quality

* Only **38.78%** of voyage records contain complete arrival information.
* During the initial analysis, the calculated average departure delay was **-30.57 hours**, suggesting that vessels were departing more than a day earlier than scheduled. This result was operationally impossible and indicated underlying data quality issues rather than actual vessel performance.

Further investigation revealed that the Estimated Time of Departure (ETD) and Actual Time of Departure (ATD) were frequently associated with different voyages, resulting in incorrect delay calculations. 

### Departure Performance

After removing invalid records:

* Average Departure Delay = **0.24 hours (14 minutes)**

instead of the misleading raw average of **-30.57 hours**.

### Vessel Performance

Megastar achieved the highest on-time departure performance at **16.38%**, while Europa recorded **4.89%**.

### Operational Finding

The analysis demonstrates that data validation is critical before calculating logistics KPIs, as poor-quality operational data can significantly distort performance measurements.

---

# Business Recommendations

Based on the analysis:

* Improve AIS data completeness and timestamp validation.
* Standardize data collection processes across voyages.
* Monitor on-time departure and arrival KPIs continuously.
* Investigate vessels with consistently lower on-time performance.
* Implement automated data quality checks before KPI reporting.

---

# Tools Used

* SQLite
* Power BI
* DAX
* Microsoft Excel

---

# Skills Demonstrated

* Data Cleaning
* SQL
* Power BI
* DAX
* KPI Development
* Dashboard Design
* Data Validation
* Business Analytics
* Supply Chain Analytics
* Maritime Logistics Analytics

---

# Project Files

* Power BI Dashboard
* SQLite Queries
* Dataset (Kaggle)
* Project Documentation

---
