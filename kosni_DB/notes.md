Step-by-Step Implementation Plan

Step 1: Analysis and Design

    1.1. ER Diagram --DONE

        Carefully read and understand the project requirements (provided in your PDF).

        Identify entities, attributes, relationships, and constraints.

        Design the Entity-Relationship (ER) Diagram using an ER diagram tool (like draw.io, Lucidchart, etc.).

    1.2. Relational Diagram --DONE

        Convert your ER diagram into a relational database schema.

        Identify primary keys, foreign keys, and other constraints.

        Document your relational schema clearly.

Step 2: Database Setup

    2.1. Choose Database

        Decide between MariaDB/MySQL and PostgreSQL.

        Configure your database using Docker Compose based on the chosen database.

    2.2. Docker Compose for LAMP stack

        Follow this guide to set up your LAMP stack with Docker Compose.

        Verify your Docker setup is working correctly (Apache server, PHP, MySQL/MariaDB).

Step 3: Database Creation and Initial Data

    3.1. Write SQL scripts

        install.sql: Write SQL DDL scripts to create tables, define indexes, and constraints.

        load.sql: Populate your tables with data (at least 50 artists/bands, 30 stages, 100 performances, 10 festivals, 200 tickets, etc., as required).

Step 4: SQL Queries Implementation

    Implement SQL queries clearly described in the provided PDF.

    Create separate .sql files for each query (e.g., Q01.sql).

    Run these queries on your database to verify they return the correct results.

    Save query results in text files (e.g., Q01_out.txt).

    For queries #4 and #6 specifically:

        Provide alternative queries using different join strategies and index hints.

        Capture query plans (EXPLAIN/TRACE) and document the analysis.

Step 5: Documentation

    README.md

        Clearly describe project assumptions and technical decisions.

        Summarize setup instructions and key points of your project.

    docs/report.pdf

        Summarize all steps with screenshots.

        Especially focus on documenting queries #4 and #6 in detail.

Step 6: Application Logic (Optional but recommended)

    Depending on your requirements, you may need to implement additional logic in PHP/Java/Python/JavaScript for certain functionalities such as ticket management, evaluation systems, etc.

    Remember: ORM tools are not allowed; interactions with DB must use raw SQL.

Step 7: Submission Preparation

    Structure your files and folders exactly as requested:

    your_project.zip
    ├── README.md
    ├── diagrams
    │   ├── er.pdf
    │   └── relational.pdf
    ├── sql
    │   ├── install.sql
    │   ├── load.sql
    │   ├── Q01.sql
    │   ├── Q01_out.txt
    │   └── ...
    ├── docs
    │   └── report.pdf
    └── (optionally) code
        └── ...

    Submit by the deadline (12/05/2025).

Step 8: Demonstration Preparation

    Make sure your application is fully operational on your laptop.

    Prepare a printed report including at least ER Diagram, Relational Diagram, and DDL scripts.

📌 Recommended Tools

    Docker & Docker Compose for setup and deployment.

    draw.io / diagrams.net or Lucidchart for diagrams.

    MySQL Workbench / pgAdmin for managing your database schema and running queries.

    Visual Studio Code or similar IDE for coding and SQL scripting.