IF OBJECT_ID('events', 'U') IS NOT NULL
DROP TABLE events
GO

CREATE TABLE events (
    event_id INT IDENTITY(1,1) PRIMARY KEY,
    unix_time BIGINT,
    sensor_alias VARCHAR(31),
    temperature DECIMAL(4,2),
    humidity DECIMAL(4,2),
    pressure DECIMAL(6,2),
    acceleration FLOAT
);
GO