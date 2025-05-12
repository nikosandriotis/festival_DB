# festival_DB
NTUA Databases course, 6th semester, 2024-2025
# DB Installation steps
For this project I used a Linux, Apache, MariaDB, PHP (LAMP) stack, installed following instructions from https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mariadb-php-lamp-stack-on-debian-11
# Schema creation, data loading
With MySQL running, we can go ahead and create our database and schema. This is done by going to the /sql directory and running the install.sql script
```
sudo mysql -u root -p < install.sql
```
This will create the database _kosni_db_ and then create all the necessary tables, triggers and procedures.

Next the loading of the data in the DB is done via the load.sql script:
```
sudo mysql -u root -p < load.sql
```
# GUI
For managing the DB and executing queries I am using SchemaDB, which is super easy to set up, while the MySQL server is up and running
![image](https://github.com/user-attachments/assets/ca74f209-5018-40f6-b755-c89d1692ab42)

There are also 2 generated files (a pdf and a html) from schemaDB which serve as a reference to the DB. In the html one, it allows the user to hover over the relational diagramm and see the relations clearly.
