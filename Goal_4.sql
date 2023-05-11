EXPLAIN ANALYZE SELECT gid, name, ST_AsText(geom) AS location
FROM public.geo_features
WHERE cuisine = 'coffee_shop' LIMIT 10;

EXPLAIN ANALYZE SELECT 
    ST_Distance(
        ST_Transform(a.geom, 3857),
        ST_Transform(b.geom, 3857)
    ) AS distance_meters
FROM 
    public.geo_features AS a,
    public.geo_features AS b
WHERE
    a.gid = 1 AND
    b.gid = 2;

EXPLAIN ANALZE WITH buffer_areas AS (
  SELECT ST_Union(ST_Buffer(ST_Transform(geom, 3857), 500)) AS geom
  FROM public.geo_features
  WHERE amenity = 'cafe' AND building = 'yes'
)
SELECT ST_Area(ST_Transform(geom, 3857)) AS area_sq_meters
FROM buffer_areas;
