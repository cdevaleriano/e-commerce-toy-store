# e-commerce-toy-store

## Business Problem Statement
  A toy store e-commerce owner wants to determine the session-to-order conversion rate for their toy bears.

## Dataset
  This project utilizes data from Maven Analytics Fuzzy Factory Set. The data reaches from March 2012 to March 2015 containing data per site entry with corresponding device of origin.

## Methodology
  All questions were answered in PostgreSQL. Subqueries, CTEs, and window functions were used for YoY changes and customer segmentation.

## Insights
- There is a steady growth in the conversion rate per year showing improvement over time.
- This is further seen in the Year-over-Year analysis where recent months have atleast 20% in the YoY calculations.
- There is a massive difference in the conversion rates between desktop and mobile devices.
- Advertisements through bsearch & gsearch showed high conversion rates.

## Reommendations
- June & July 2014 have negative YoY changes. It is worth exploring the difference in marketing strategies during the time period.
- Socialbook advertisements bring the least amount of site visitors. It is worth exploring different advertisement variations on the platform.
- Conduct Funnel Analysis to explore until what point do potential customers leave.
- With the low conversion rate of mobile users compared to desktop users, improvements can be made to mobile page view of the website to improve conversions.
