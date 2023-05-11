SELECT 
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
