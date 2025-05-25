-- create a database

CREATE DATABASE conservation_db;

-- Creating ranger table
CREATE TABLE rangers (
    ranger_id SERIAL PRIMARY KEY,
    "name" VARCHAR(50) NOT NULL,
    region VARCHAR(25) NOT NULL
);

-- Creating species table
CREATE TABLE species (
    species_id SERIAL PRIMARY KEY,
    common_name VARCHAR(100) NOT NULL,
    scientific_name VARCHAR(100) NOT NULL,
    discovery_date DATE,
    conservation_status VARCHAR(50)
);

-- Creating sightings table
CREATE TABLE sightings (
    sighting_id SERIAL PRIMARY KEY,
    ranger_id INTEGER NOT NULL REFERENCES rangers (ranger_id),
    species_id INTEGER NOT NULL REFERENCES species (species_id),
    sighting_time TIMESTAMP NOT NULL,
    location VARCHAR(50) NOT NULL,
    notes TEXT
);

-- adding sample data to rangers table

INSERT INTO
    rangers (name, region)
VALUES (
        'Alice Green',
        'Northern Hills'
    ),
    ('Bob White', 'River Delta'),
    (
        'Carol King',
        'Mountain Range'
    );

-- adding sample data to species table

INSERT INTO
    species (
        common_name,
        scientific_name,
        discovery_date,
        conservation_status
    )
VALUES (
        'Snow Leopard',
        'Panthera uncia',
        '1775-01-01',
        'Endangered'
    ),
    (
        'Bengal Tiger',
        'Panthera tigris tigris',
        '1758-01-01',
        'Endangered'
    ),
    (
        'Red Panda',
        'Ailurus fulgens',
        '1825-01-01',
        'Vulnerable'
    ),
    (
        'Asiatic Elephant',
        'Elephas maximus indicus',
        '1758-01-01',
        'Endangered'
    );

-- adding sample data to sighting table
INSERT INTO
    sightings (
        species_id,
        ranger_id,
        location,
        sighting_time,
        notes
    )
VALUES (
        1,
        1,
        'Peak Ridge',
        '2024-05-10 07:45:00',
        'Camera trap image captured'
    ),
    (
        2,
        2,
        'Bankwood Area',
        '2024-05-12 16:20:00',
        'Juvenile seen'
    ),
    (
        3,
        3,
        'Bamboo Grove East',
        '2024-05-15 09:10:00',
        'Feeding observed'
    ),
    (
        1,
        2,
        'Snowfall Pass',
        '2024-05-18 18:30:00',
        NULL
    );

-- 1. Register a new ranger with provided data with name = 'Derek Fox' and region = 'Coastal Plains'

INSERT INTO
    rangers (name, region)
VALUES ('Derek Fox', 'Coastal Plains');

-- 2. Count unique species ever sighted.

SELECT count(DISTINCT (species_id)) as unique_species_count
FROM sightings;

-- 3.  Find all sightings where the location includes "Pass".

SELECT
    sighting_id,
    species_id,
    ranger_id,
    "location",sighting_time,notes
FROM sightings
WHERE
    location LIKE '%Pass%';

-- 4.  List each ranger's name and their total number of sightings.

SELECT r.name, count(s.sighting_id) as total_sightings
FROM rangers r
    JOIN sightings s ON s.ranger_id = r.ranger_id
GROUP BY
    r.name
ORDER BY r.name;

-- 5.  List species that have never been sighted.

SELECT sp.common_name
FROM species sp
    LEFT JOIN sightings si ON si.species_id = sp.species_id
WHERE
    si.sighting_id is NULL;
;

-- 6. Show the most recent 2 sightings.

SELECT sp.common_name, si.sighting_time, r."name"
FROM public.species sp
    JOIN public.sightings si ON si.species_id = sp.species_id
    JOIN public.rangers r ON r.ranger_id = si.ranger_id
ORDER BY sighting_time DESC
LIMIT 2;

-- 7. Update all species discovered before year 1800 to have status 'Historic'.

UPDATE species
SET
    conservation_status = 'Historic'
WHERE
    discovery_date < '1800-01-01';

-- 8 .Label each sighting's time of day as 'Morning', 'Afternoon', or 'Evening'.
                --Morning: before 12 PM
                -- Afternoon: 12 PM–5 PM
                -- Evening: after 5 PM

SELECT
    sighting_id,
    CASE
        WHEN sighting_time::time < '12:00:00' THEN 'Morning'
        WHEN sighting_time::time < '17:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM sightings;

--9. Delete rangers who have never sighted any species

DELETE FROM rangers r
WHERE
    ranger_id NOT IN (
        SELECT r.ranger_id
        FROM sightings s
        WHERE
            s.ranger_id = r.ranger_id
    );