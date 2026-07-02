# Vessel_performance_analytics
Vessel Performance Analytics using SQL + DAX + Power BI

Headline: 824,000 Voyages, 4 Vessels, and One Massive Data Cleaning Challenge 🚢

I just wrapped up a deep-dive analytics project on maritime supply chain performance—and the numbers were wilder than I expected.

The Project:
Built a Power BI dashboard analyzing AIS vessel data between Helsinki (FIHEL) and Tallinn (EETLL) for 4 major ships: Europa, Finlandia, Megastar, and Star.

The Messy Reality:
The raw data showed an "Average Departure Delay" of -30.57 hours 🤯. That implied ships were leaving almost a day and a half early—which is physically impossible.
Why? The ETD (Estimated) and ATD (Actual) timestamps often belonged to completely different voyages.

The Fix:

Used SQLite to standardize date formats and remove duplicates.

Applied a logical filter (-2 to +24 hours) in DAX to isolate only realistic departure windows.

Preserved the raw 824K total voyage count while calculating clean, filtered metrics.

The Dashboard Snapshot:
✅ Total Voyages: 824K
✅ Data Completeness: 38.78% (only ~39% have full arrival data)
✅ Filtered Avg Delay: 0.24 hours (~14 mins)
✅ Filtered On-Time Departure: 11.76%
✅ On-Time Arrival: 12.49%

Biggest Takeaway:
The data revealed that Megastar (16.38%) consistently outperforms Europa (4.89%) in on-time departures. More importantly, the 61% missing arrival data shows just how challenging AIS data integrity is in real-world maritime logistics.

Tools: SQLite | Power BI | DAX | Data Cleaning

If you are interested in how I built this or want to check out the full interactive dashboard, I have uploaded the project to GitHub (link in the comments!).

#DataAnalytics #PowerBI #SQLite #DataCleaning #AIS #MaritimeLogistics #SupplyChain #DataScience


