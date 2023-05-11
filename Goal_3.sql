WITH buffer_areas AS (
  SELECT ST_Union(ST_Buffer(ST_Transform(geom, 3857), 500)) AS geom
  FROM public.geo_features
  WHERE amenity = 'cafe' AND building = 'yes'
)
SELECT ST_Area(ST_Transform(geom, 3857)) AS area_sq_meters
FROM buffer_areas;
