## **Data Insights & Quality Findings for Data Analysis**


Hi,

I wanted to share some early takeaways from the recent analysis on brand performance and customer transactions.
Along the way, I also noticed a few data gaps and inconsistencies that could impact how reliable the results are.
Below is a summary of the main insights, along with a few data quality points and decisions that might be worth looking into further.


## **Key Findings**

**1. Top 5 Brands by Receipts Scanned For Most Recent Month**

Due to insufficient data in February 2021 (the most recent month), I based my analysis on January 2021 instead.
Top brands:

|          BRAND            |    RANK   | 
|:-------------------------:|:---------:|
| KLEENEX                   |     1     |
| KNORR                     |     2     |
| PEPSI                     |     2     |
| KRAFT                     |     3     |
| RICE A RONI               |     4     |
| DORITOS                   |     4     |
| SWANSON                   |     5     |
| YUBAN COFFEE              |     5     |
| TOSTITOS                  |     5     |
| DOLE CHILLED FRUIT JUICES |     5     |


**2. Comparison of Brand Rankings Between Recent and Previous Month**

I attempted to compare brand rankings between the most recent month (February 2021) and the previous month (January 2021).
However, February 2021 had too few receipts, making it impossible to track how brands moved up or down in rank.
This insight is crucial for understanding brand popularity over time, helping us track whether a brand is gaining 
or losing relevance among consumers. 

**3. Average Spend by Receipt Status**

Receipts marked as `Finished` (assumed to be Accepted) had a higher average spend ($80.85) compared to `Rejected` receipts ($23.33).
This indicates that accepted receipts purchases reflect more meaningful purchases.

**4. Total items purchased by Receipt Status**

`Finished` receipts included a total of 8,184 items purchased, while `Rejected` ones had only 173.
This supports the idea that accepted receipts generally reflect larger and more meaningful purchases.

**5. Most Spending Among New Users**

`KNORR` had the highest total spend among users created within the past 6 months ($536.56), followed by `KLEENEX` ($356.07) and `DORITOS` ($323.64).
This indicates strong engagement from new users toward these brands.

**6. Most Transactions Among New Users**

`KLEENEX` had the highest transaction count among users created within the past 6 months (15 receipts), followed by `PEPSI` (14 receipts) and ` KNORR` (13 receipts).
Some brands have high engagement but lower spend per transaction, while others drive larger purchases.


## **Data Quality Issues**
Here’s a quick summary of some data issues I found, along with their potential impact and a few open questions. Clarifying these points will help us improve the quality of our analysis and make sure it reflects what’s actually happening in the business.


1. Understanding user duplicates

We need to understand whether users can create multiple accounts, which could lead to duplicates in our database.
In the current dataset, 283 users (or 57%) appear as duplicates. Are these duplicates real users with mutiple accounts,
or are they caused by system-generated errors?
    - *Impact:* These duplicates were not included in the previous analysis, meaning the insights might not fully reflect user behavior.
    However, if not removed it may increase the user count.

2. Understanding receipts without registered users

We need to clarify whether a user can submit a receipt without first creating an account.
Currently, 13% of finalized receipts are linked to users who do not exist in our database. This raises an important question: how these receipts are being processed? 
    - *Impact:* The analysis only considered receipts from registered users, meaning receipts from unregistered users were excluded.

3. Understanding the `fetch-staff` user role

We need to better understand the `fetch-staff` user role and how it differs from `consumer` users. 
In the dataset, 15% of users (82) have the `fetch-staff` role, while 413 users are classified as `consumer`.
    - *Impact:* Only `consumer` users were considered, meaning `fetch-staff` users were excluded since the study only concerns consumers.

4. Clarifying receipt statuses

We need to better understand how and when receipt statuses (`Pending`, `Flagged`, `Submitted`, `Finished`, and `Rejected`) are assigned.
    - *Impact:* I treated `Finished` as equivalent to `Accepted` when comparing receipts by status. However, for all other analyses, I used only `Finished` to maintain consistency.

5. Understanding the brand creation process

We need to gain better clarity on how new brands are created or registered in the system.
Currently, 23% of brands do not have a brand code, even though they contain key information such as a brand name. 
    - *Impact:* I excluded all records with missing brand codes to ensure data consistency and avoid incorrect brand attribution in the analysis. However this may affect marketing or product decisions as we are not considering some brands.

6. Receipts with zero purchased items still earning points

I identified `Finished` receipts where the number of purchased items is zero, or the total spend is $0 but these receipts still earned reward points. This raises an important question: how exactly are rewards being calculated?
    - *Impact:* These cases were not removed from the dataset, as we still need to understand whether they are valid or represent a data quality issue. But incorrectly assigned rewards could reflect both system errors and negatively impact the user experience.


Understanding these issues will help us refine the analysis and feel more confident in the results. 
Additionally, we need to confirm whether the impacts identified and the decisions taken align with business expectations.
Would love to hear your thoughts! Let me know if it would be helpful to set up a quick chat to go over these points together.

Thanks,

Milena Pininga
