# Flights analysis - Airline Delays with Weather and Airport Detail
Consulting project for one of the air carriers to optimize the process of providing and analyzing data. The data we will be using comes from the Kaggle platform [LINK](https://www.kaggle.com/datasets/threnjen/2019-airline-delays-and-cancellations/). Due to its volume (more than 9 million rows), the dataset has been reduced accordingly to facilitate the work. The project is conducted using Python, SQL and its libraries.

The goal of this project is to:
- create a mechanism that retrieves data from the provided API - ***Python - API, Pandas***
- create a database used for analytical and reporting purposes - ***SQL - psycopg2***
- feed the downloaded data into the database - ***Python - Pandas, SQL- SQLAlchemy***
- perform an exploratory analysis of the dataset - ***Python - Pandas, Numpy, SQL- SQLAlchemy, Data vizualization - Plotly, Seaborn, Matplotlib***
- create an operational report - ***Python - Pandas, Numpy, SQL- SQLAlchemy, Data vizualization - Dash***.

Repository files content:
- data - folder where the data are located
- data\raw - folder with source data, in our case from the API
- data\processed -  folder with data created during analysis
- data\readme.txt - business-technical documentation of the data available in the API
- notebooks - folder with *.ipynb files
- requirements.txt - file with the required list of libraries to recreate the virtual environment
