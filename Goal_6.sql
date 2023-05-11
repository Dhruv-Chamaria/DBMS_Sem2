CREATE INDEX idx_geo_features_geom ON public.geo_features USING gist(geom);

SELECT gid, name, ST_AsText(geom) AS location,
       ST_Distance(ST_Transform(geom, 3857), ST_Transform(ST_SetSRID(ST_Point(-74.0014, 40.7289), 4326), 3857)) AS distance_meters
FROM public.geo_features
WHERE amenity = 'cafe'
ORDER BY distance_meters ASC
LIMIT 5;


WITH buffer_areas AS (
  SELECT gid, ST_Union(ST_Buffer(ST_Transform(geom, 3857), 500)) AS geom
  FROM public.geo_features
  WHERE amenity = 'cafe' AND building = 'yes'
  GROUP BY gid
),
buffer_areas_with_area AS (
  SELECT gid, geom, ST_Area(ST_Transform(geom, 3857)) AS area_sq_meters
  FROM buffer_areas
)
SELECT gid, area_sq_meters
FROM buffer_areas_with_area
ORDER BY area_sq_meters DESC
LIMIT 3;

