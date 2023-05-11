SELECT gid, name, ST_AsText(geom) AS location
FROM public.geo_features
WHERE cuisine = 'coffee_shop'
LIMIT 10;

CREATE INDEX idx_geo_features_geom ON public.geo_features USING gist(geom);


SELECT gid, name, ST_AsText(geom) AS location,
       ST_Distance(ST_Transform(geom, 3857), ST_Transform(ST_SetSRID(ST_Point(-74.0014, 40.7289), 4326), 3857)) AS distance_meters
FROM public.geo_features
WHERE amenity = 'cafe' AND ST_DWithin(ST_Transform(geom, 3857), ST_Transform(ST_SetSRID(ST_Point(-74.0014, 40.7289), 4326), 3857), 5000)
ORDER BY distance_meters ASC
LIMIT 5;                     

CREATE INDEX idx_geo_features_geom ON public.geo_features USING gist(geom);

CREATE INDEX idx_cuisine ON public.geo_features (cuisine);
