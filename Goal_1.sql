SELECT gid, name, ST_AsText(geom) AS location
FROM public.geo_features
WHERE cuisine = 'coffee_shop' LIMIT 10;
