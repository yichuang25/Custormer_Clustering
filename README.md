# Customer Clustering Analysis Project
## Overview
This project aims to segment customers of a financial institution based on their behavior and transaction patterns. Utilizing data from Transaction Data, Customer Data, and BLS Statistics, we apply K-Means, HDBSCAN, and OPTICS clustering algorithms to identify distinct customer groups and understand their characteristics.

## Objective

The primary objective is to analyze customer behavior and transaction patterns to effectively segment customers. This segmentation will aid in tailoring financial products and services to meet the needs of different customer groups.

## Setup and Usage
* Database Creation and Initialization:
  - Intall Docker
  - Run the following command to create a MySQL container:
    ```bash
    docker compose up
    ```
  - Follow the steps in [database_creation.ipynb](/src/database_creation.ipynb) to set up the database and import the data.
* Stored Procedure and Trigger Creation:
  * Use [stored_procedure.ipynb](src/stored_procedure.ipynb) and [stored_procedure.sql](src/stored_procedure.sql) to create and implement the stored procedures in your SQL database.
* Customer Segmentation Analysis:
  * Execute the [customer_segmentation.ipynb](src/customer_segementation.ipynb) notebook to perform the clustering analysis and view the results.

## Data Source
1. **Transaction Data**: Consists of transaction amounts, timestamps, customer IDs, and transaction types.
2. **Customer Data**: Provides demographic information, including age, gender, profession, work experience, and family size.
3. **BLS Statistics**: Features the Annual Median Wages data from the U.S. Bureau of Labor Statistics.

## Report
The project report can be found [here](/report.pdf).


## License
This project is licensed under the MIT License - see the LICENSE.md file for details.

