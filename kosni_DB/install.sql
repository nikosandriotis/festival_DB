-- install.sql

-- Create the database
CREATE DATABASE IF NOT EXISTS kosni_db;
USE kosni_db;

-- Include the schema definitions
SOURCE schema.sql;