# DBMS
<h1>Step 0: Install Postgis and Enable it on Postgres</h1>
Created a new PostgreSQL database and enable the PostGIS extension:<br><br>
<img width="626" alt="Screenshot 2023-05-10 at 10 47 59 PM" src="https://github.com/Astroboyag/DBMS/assets/46861452/78d047fa-95da-41a1-8b97-419b212dfe94">
<h1>Step 1: Get the Data from an online source.</h1>

To download OSM data in the desired format, follow these steps:

1) Go to the Overpass Turbo website: https://overpass-turbo.eu/
2) In the top left corner, click the "Wizard" button.
3) Enter a search query to filter the data based on your project's needs. For example, you can search for specific types of points of interest like "amenity=cafe" to retrieve all cafes in the current map view.
4) Click "Build and Run Query" to execute the query.
5) Once the query is completed, the map will show the matching features. You can pan and zoom to adjust the area of interest.
6) Click the "Export" button in the top right corner.
7) Choose the desired format (GeoJSON or KML) and click "download."

Downloaded all data for cafes in New York City Area in GeoJSON format. Used the following query: <br><br>
<img width="623" alt="Screenshot 2023-05-10 at 9 40 02 PM" src="https://github.com/Astroboyag/DBMS/assets/46861452/16c0196f-4a3c-44fe-ae73-56312fbe0fbe"><br><br>
<h2>Step 2: Get the Data from an online source.</h2>

Then we imported the data using the following command:

ogr2ogr -f "PostgreSQL" PG:"dbname=gis_analysis user=postgres host=/var/run/postgresql port=5432" "/home/ubuntu/export.geojson" -nln public.geo_features -lco GEOMETRY_NAME=geom -lco FID=gid -lco PRECISION=NO -nlt PROMOTE_TO_MULTI -a_srs EPSG:4326

<h1>Goals</h1>

<h2>Goal 1: Retrieve Locations of specific features</h2>

We retreived cafe which are marked as coffee_shop as cuisine. We used the following query for the same:

SELECT gid, name, ST_AsText(geom) AS location<br>
FROM public.geo_features<br>
WHERE cuisine = 'coffee_shop' LIMIT 10;<br><br>
Below is the output:<br><br>
<img width="620" alt="Screenshot 2023-05-10 at 9 44 43 PM" src="https://github.com/Astroboyag/DBMS/assets/46861452/d41ac01d-4ed5-4450-a071-79d231b7ebaa"><br><br>
<h2>Goal 2: Retrieve Locations of specific features</h2>
To calculate the distance between two points, we used the ST_Distance function in PostGIS. First, we need to pick two points based on gid value and then use the geom column for the distance calculation.<br><br>

Below is the query that we used for gid 1 and gid 2<br><br>
SELECT<br>
    ST_Distance(<br>
        ST_Transform(a.geom, 3857),<br>
        ST_Transform(b.geom, 3857)<br>
    ) AS distance_meters<br>
FROM<br>
    public.geo_features AS a,<br>
    public.geo_features AS b<br>
WHERE<br>
    a.gid = 1 AND<br>
    b.gid = 2;<br>
    
Below is the output: <br><br>

<img width="514" alt="Screenshot 2023-05-10 at 10 05 41 PM" src="https://github.com/Astroboyag/DBMS/assets/46861452/009d09e4-b718-46ad-a06a-7f99f3e1de6f"><br><br>
<h2>Goal 3: Calculate Areas of Interest (specific to each group)</h2>
Based on the data that we have let's create a buffer of 500 meters around cafes that are located in buildings and then calculate the area of the resulting polygons.<br>

This query creates a temporary table called buffer_areas with a single row containing the union of the 500-meter buffer areas around cafes that are in buildings. Then, it calculates the area of the resulting polygon in square meters.<br>

WITH buffer_areas AS (<br>
  SELECT ST_Union(ST_Buffer(ST_Transform(geom, 3857), 500)) AS geom<br>
  FROM public.geo_features<br>
  WHERE amenity = 'cafe' AND building = 'yes'<br>
)<br>
SELECT ST_Area(ST_Transform(geom, 3857)) AS area_sq_meters<br>
FROM buffer_areas;<br>

Following is the output: <br>

<img width="622" alt="Screenshot 2023-05-10 at 10 10 16 PM" src="https://github.com/Astroboyag/DBMS/assets/46861452/aec5dc72-a198-40af-a7aa-9bb60fafdb82"><br><br>

<h2>Goal 4: Analyze the Queries </h2>
Analyzing queries can help you understand the performance and efficiency of your queries. In PostgreSQL, you can use the EXPLAIN or EXPLAIN ANALYZE command to get insights about your queries. The EXPLAIN command provides the query execution plan, while EXPLAIN ANALYZE also executes the query and provides additional details about actual execution times and rows returned.<br><br>
Here is the analysis of Goal 1:<br><br>
<img width="623" alt="Screenshot 2023-05-10 at 10 12 18 PM" src="https://github.com/Astroboyag/DBMS/assets/46861452/3a61daa8-d64b-4f5b-a257-154b1d57b145"><br><br>
Here is the analysis for Goal 2:<br><br>
<img width="626" alt="Screenshot 2023-05-10 at 10 13 10 PM" src="https://github.com/Astroboyag/DBMS/assets/46861452/3faa6ab3-39c5-4678-a99c-26523707f36c"><br><br>
Here is the analysis for Goal 3:<br><br>
<img width="624" alt="Screenshot 2023-05-10 at 10 14 01 PM" src="https://github.com/Astroboyag/DBMS/assets/46861452/236ee57b-ab10-41c5-927c-d89701ed4f20"><br><br>

<h2>Goal 5: Sorting and Limit Executions</h2>
Sorting and limiting query results can help us retrieve only the most relevant data or present the results in a more user-friendly manner. You can use the ORDER BY clause to sort the results and the LIMIT clause to limit the number of rows returned.<br><br>
Sorting and Limit on Goal 1:<br><br>
SELECT gid, name, ST_AsText(geom) AS location<br>
FROM public.geo_features<br>
WHERE cuisine = 'coffee_shop' LIMIT 10;<br>
<img width="624" alt="Screenshot 2023-05-10 at 10 16 19 PM" src="https://github.com/Astroboyag/DBMS/assets/46861452/fa8ddcf0-994a-4262-b11e-8cdced24405e"><br><br>
Sorting and Limit on Goal 2:<br><br>
SELECT gid, name, ST_AsText(geom) AS location,<br>
       ST_Distance(ST_Transform(geom, 3857), ST_Transform(ST_SetSRID(ST_Point(-74.0014, 40.7289), 4326), 3857)) AS distance_meters<br>
FROM public.geo_features<br>
WHERE amenity = 'cafe'<br>
ORDER BY distance_meters ASC<br>
LIMIT 5;<br><br>
<img width="625" alt="Screenshot 2023-05-10 at 10 17 50 PM" src="https://github.com/Astroboyag/DBMS/assets/46861452/683e3369-46bd-44bf-9432-891afc4bea53"><br><br>
Sorting and Limit on Goal 3:<br><br>
WITH buffer_areas AS (<br>
  SELECT gid, ST_Union(ST_Buffer(ST_Transform(geom, 3857), 500)) AS geom<br>
  FROM public.geo_features<br>
  WHERE amenity = 'cafe' AND building = 'yes'<br>
  GROUP BY gid<br>
),<br>
buffer_areas_with_area AS (<br>
  SELECT gid, geom, ST_Area(ST_Transform(geom, 3857)) AS area_sq_meters<br>
  FROM buffer_areas<br>
)<br>
SELECT gid, area_sq_meters<br>
FROM buffer_areas_with_area<br>
ORDER BY area_sq_meters DESC<br>
LIMIT 3;<br><br>
<img width="625" alt="Screenshot 2023-05-10 at 10 19 47 PM" src="https://github.com/Astroboyag/DBMS/assets/46861452/e6dfbc9a-9aa8-4d0b-99eb-8c371e7ea769"><br><br>
<h2>Goal 6: Optimize the queries to speed up execution time (10 marks)</h2>
Query optimization can be done using indexes, simplifying calculations, or reducing the number of rows scanned. Here are some optimization techniques applied to the queries we used before:<br>

Optimization of Goal 1:<br><br>

To optimize this query, we can create an index on the cuisine column, which will speed up the selection process:<br><br>
CREATE INDEX idx_cuisine ON public.geo_features (cuisine);<br><br>
The query then remains the same:<br><br>
<img width="622" alt="Screenshot 2023-05-10 at 10 22 03 PM" src="https://github.com/Astroboyag/DBMS/assets/46861452/031c1173-fafe-40af-8a9b-bc212093ea86"><br><br>
<img width="626" alt="Screenshot 2023-05-10 at 10 23 08 PM" src="https://github.com/Astroboyag/DBMS/assets/46861452/db4a69be-e590-450e-9cac-1d4844a64e7b"><br><br>
By creating an index on the cuisine column, the database will be able to quickly filter the rows that match the condition, improving the query's performance. Keep in mind that creating indexes may increase storage space and impact data modification performance, so you should find the right balance between query performance and storage/modification costs.<br>
Optimization of Goal 2:<br><br>
We can create a spatial index on the geom column to speed up spatial operations:<br><br>
CREATE INDEX idx_geo_features_geom ON public.geo_features USING gist(geom);<br><br>
The query remains the same:<br><br>
SELECT gid, name, ST_AsText(geom) AS location,<br>
       ST_Distance(ST_Transform(geom, 3857), ST_Transform(ST_SetSRID(ST_Point(-74.0014, 40.7289), 4326), 3857)) AS distance_meters<br>
FROM public.geo_features<br>
WHERE amenity = 'cafe'<br>
ORDER BY distance_meters ASC<br>
LIMIT 5;<br>
<img width="625" alt="Screenshot 2023-05-10 at 10 25 36 PM" src="https://github.com/Astroboyag/DBMS/assets/46861452/cd8a02b4-1dac-4809-b692-2f912d57b304"><br><br>
<img width="624" alt="Screenshot 2023-05-10 at 10 26 16 PM" src="https://github.com/Astroboyag/DBMS/assets/46861452/e3012aee-ef06-4f7e-a155-11514ea612fd"><br><br>
Optimization of Goal 3:<br><br>
We can use the previously created spatial index on the geom column to speed up the spatial operations in this query:<br>
WITH buffer_areas AS (<br>
  SELECT gid, ST_Union(ST_Buffer(ST_Transform(geom, 3857), 500)) AS geom<br>
  FROM public.geo_features<br>
  WHERE amenity = 'cafe' AND building = 'yes'<br>
  GROUP BY gid<br>
),<br>
buffer_areas_with_area AS (<br>
  SELECT gid, geom, ST_Area(ST_Transform(geom, 3857)) AS area_sq_meters<br>
  FROM buffer_areas<br>
)<br>
SELECT gid, area_sq_meters<br>
FROM buffer_areas_with_area<br>
ORDER BY area_sq_meters DESC<br>
LIMIT 3;<br><br>
These optimizations should improve query performance by utilizing indexes for filtering and spatial operations. Note that creating indexes can increase storage space and impact the performance of data modifications (insert, update, delete), so it's essential to find the right balance between query performance and storage/modification costs.<br><br>
<img width="625" alt="Screenshot 2023-05-10 at 10 29 48 PM" src="https://github.com/Astroboyag/DBMS/assets/46861452/c04368d6-8922-40c2-861d-440917f80a22"><br><br>
<h2>Goal 7: N-Optimization of Queries</h2>
N-optimization refers to optimizing queries in a way that they run efficiently even when the number of rows in the database increases significantly. This can be achieved by using indexes, limiting the amount of data processed, and selecting only the necessary columns. Below are the N-optimizations for the queries we used.<br>
Optimization of Goal 1:<br>
To N-optimize this query, we can create an index on the cuisine column, which will help filter rows more efficiently as the database grows:<br>
   CREATE INDEX idx_cuisine ON public.geo_features (cuisine);<br>
 Then, run the original query:<br>
SELECT gid, name, ST_AsText(geom) AS location<br>
FROM public.geo_features<br>
WHERE cuisine = 'coffee_shop'<br>
LIMIT 10;<br>
<img width="628" alt="Screenshot 2023-05-10 at 10 32 40 PM" src="https://github.com/Astroboyag/DBMS/assets/46861452/848fa4cf-86c1-4176-be43-79a4e0f69659"><br>
By creating an index on the cuisine column, the database will be able to filter the rows with 'coffee_shop' value faster, even when the number of rows in the database increases significantly.<br>
N-Optimization of Goal 2:<br>
In this query, we created a spatial index on the geom column in a previous step:<br>
CREATE INDEX idx_geo_features_geom ON public.geo_features USING gist(geom);<br>
However, the ST_Distance function may not be efficient with a large number of rows. To improve the performance, we can use the ST_DWithin function to filter only the cafes within a certain distance of the specific point, and then calculate the exact distance:<br>

SELECT gid, name, ST_AsText(geom) AS location,<br>
       ST_Distance(ST_Transform(geom, 3857), ST_Transform(ST_SetSRID(ST_Point(-74.0014, 40.7289), 4326), 3857)) AS distance_meters<br>
FROM public.geo_features<br>
WHERE amenity = 'cafe' AND ST_DWithin(ST_Transform(geom, 3857), ST_Transform(ST_SetSRID(ST_Point(-74.0014, 40.7289), 4326), 3857), 5000)<br>
ORDER BY distance_meters ASC<br>
LIMIT 5;<br>
<img width="624" alt="Screenshot 2023-05-10 at 10 35 39 PM" src="https://github.com/Astroboyag/DBMS/assets/46861452/997db8ce-ab5b-4d37-920b-3fe4b87e71eb"><br>
This query will first filter cafes within 5000 meters of the specific point and then sort them by distance.<br>
 N-Optimization of Goal 3:<br>
As we already created a spatial index on the geom column, it will help in spatial operations for this query:<br>

CREATE INDEX idx_geo_features_geom ON public.geo_features USING gist(geom);<br>

Additional Query: Cafes with cuisine = 'coffee_shop'<br>

We created an index on the cuisine column to optimize this query:<br>

CREATE INDEX idx_cuisine ON public.geo_features (cuisine);<br>

These optimizations will help the queries run efficiently even when the number of rows in the database grows significantly.<br>
<img width="625" alt="Screenshot 2023-05-10 at 10 37 29 PM" src="https://github.com/Astroboyag/DBMS/assets/46861452/20e23359-174f-43d9-98ef-fe92ce963510">
       <h2>Goal 8: Presentation and Posting to Individual GitHub </h2>

Here are the github links for all the 3 group members:<br>

Tarun Dagar<br>
Ankush Gurhani<br>
Dhruv Chamaria<br>

Here are the links to the Presentataion by each student:<br>

Tarun Dagar<br>
Anksuh Gurhani<br>
Dhruv Chamaria<br>
       <h2>Goal 9: Code functionality, documentation and proper output provided</h2>
This document already contains all the details.

     
     
 
   


      
       
       
       
     


       
       













