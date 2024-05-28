# purpose

- this page describes how to setup the local and cloud environments as summarized [here](/readme.md#sequence-of-steps)

# developer machine

## pre-requisites - developer machine

- **local machine**
  - ensure you have mac/linux/[WSL](https://learn.microsoft.com/en-us/windows/wsl/about) as your local development environment
  - you must have admin permissions on your local machine
- **installed software**
  - you must have [python](https://devguide.python.org/versions/) 3.8 or later and [git](https://mirrors.edge.kernel.org/pub/software/scm/git/) 2.25 or later installed on your machine
  - you must have [Docker desktop](https://www.docker.com/products/docker-desktop/) installed on your machine

## python virtual environment

- all packages needed for running this code can be deployed inside a virtual environment
- these are the steps
  - first clone this repo locally
  - then open the folder
    - `cd KnowledgeGraphAI`
- then create a Python virtual environment
  - `python3 -m venv python_venv`
- then activate the env
  - on windows - `.\python_venv\Scripts\activate`
  - on mac - `source python_venv/bin/activate`
  - and now install all dependencies
    - `pip install -r requirements.txt`

## vscode devcontainer

- if you use [vscode devcontainers](https://code.visualstudio.com/docs/devcontainers/containers) like me, then you dont have to do anything noted above in the python virtual env section
- i have setup the repo nicely to be launch-ready the moment you download it
- launch vscode, and then open the command palette (ctrl+shift+p), and then select "Remote-Containers: Open Folder in Container"
- navigate to the cloned repository folder and you are done...all requirements will be automatically installed
- you can also make modifications to these 2 files as needed
  - [devcontainer.json](./../.devcontainer/devcontainer.json)
  - [postStart.sh](./../.devcontainer/postStart.sh)

## streamlit - developer machine

- to visualize the file arrival stats using [Streamlit](https://streamlit.io), follow these steps:
  - setup your repo by downloading it and installing the required packages as shown in the python virtual environment or the vscode devcontainers sections above
  - now open this repository folder inside your terminal and run the Streamlit app:
    - `streamlit run welcome.py`
  - Streamlit will start a local web server, and you will see a URL in the terminal (usually `http://localhost:8501`)
  - open this URL in your web browser to access the interactive charts and visualizations
    To set up MySQL and Neo4j on your Mac using Docker Compose and enable data extraction from MySQL to Neo4j, follow these detailed steps. We'll also include verification steps to ensure the deployment is progressing as expected.

# install neo4j & mysql

## docker compose

- create a `docker-compose.yml` file to define the services for mysql and neo4j

```yaml
version: "3.8"

services:
  mysql:
    image: mysql:latest
    container_name: mysql-container
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: mydatabase
      MYSQL_USER: user
      MYSQL_PASSWORD: password
    ports:
      - "3306:3306"
    volumes:
      - mysql-data:/var/lib/mysql

  neo4j:
    image: neo4j:latest
    container_name: neo4j-container
    environment:
      NEO4J_AUTH: neo4j/password
    ports:
      - "7474:7474"
      - "7687:7687"
    volumes:
      - neo4j-data:/data

volumes:
  mysql-data:
  neo4j-data:
```

## start compose services

- run the docker compose file to start mysql and neo4j services

```sh
docker-compose up -d
```

- check if the containers are deployed

```sh
docker ps
```

- sample output when above command is run

```sh
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                                                      NAMES
15c08cb08a7c   mysql:latest   "docker-entrypoint.s…"   13 minutes ago   Up 10 minutes   0.0.0.0:3306->3306/tcp, 33060/tcp                          mysql-container
ef3fbeb764ba   neo4j:latest   "tini -g -- /startup…"   13 minutes ago   Up 8 minutes    0.0.0.0:7474->7474/tcp, 7473/tcp, 0.0.0.0:7687->7687/tcp   neo4j-container
```

## verify mysql setup

- connect to mysql container:

```sh
docker exec -it mysql-container mysql -u root -p
```

- enter the password `rootpassword` and verify you can log in to mysql

- verify mysql database

```sql
SHOW DATABASES;
```

- ensure `mydatabase` is listed as an output for command above
- select the database

```sql
USE mydatabase;
```

- create table and insert data

```sql
CREATE TABLE test (id INT PRIMARY KEY, name VARCHAR(50));
INSERT INTO test VALUES (1, 'TestName');
```

- exit the container by typing `exit` at the mysql prompt or by pressing `Ctrl+D`
- restart the container:

```sh
docker-compose restart mysql
```

- connect to the mysql container again

```sh
docker exec -it mysql-container mysql -u root -p
```

- verify if the table created earlier has persisted

```sql
SELECT * FROM test;
```

## verify neo4j setup

- open your web browser and navigate to `http://localhost:7474`
- log in using the username `neo4j` and password `password`
- create a node and check if it persists after restarting the neo4j container.

```cypher
CREATE (n:TestNode {name: 'TestNodeName'});
MATCH (n:TestNode) RETURN n;
```

- restart the container:

```sh
docker-compose restart mysql
```

- go back to neo4j in the browser and run the query

```sh
MATCH (n:TestNode) RETURN n;
```

- verify if the node created earlier has persisted

## verify mysql & neo4j connectivity

- **intro**
  - this section shows how to confirm if mysql and neo4j are able to talk to each other
- **mysql driver**
  - download MySQL JDBC driver from [here](https://dev.mysql.com/downloads/connector/j/)
  - from the drop-down select the option "Platform Independent" if you are on [Mac](https://stackoverflow.com/a/25548704)
  - place the jar inside the [plugins directory](/plugins)
- **apoc driver**
  - download the apoc driver from [here](https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases)
  - ensure that you download the apoc version that matches your neo4j instance version as mentioned [here](https://github.com/neo4j-contrib/neo4j-apoc-procedures?tab=readme-ov-file#version-compatibility-matrix)
  - for example, i first found out my neo4j version number using
  - the output i got was
  - so then i downloaded the version 5.19.0 from [here](https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/5.19.0/apoc-5.19.0-extended.jar)
  - place the downloaded jar inside the [plugins directory](/plugins)
- **load drivers**
  - bounce the containers
    - `docker-compose down`
    - `docker-compose up -d`
  - check if containers are running again
    - `docker ps`
- **verify connectivity**
  - open neo4j inside browser
    - `http://localhost:7474/browser/`
  - run these queries

```cypher
CALL apoc.load.driver('com.mysql.cj.jdbc.Driver');

CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/mydatabase', 'SELECT * FROM test') YIELD row
RETURN row;
```

- **check response**
  - you should see the record you created earlier inside mysql

```json
{
	"id": 1,
	"name": "TestName"
}
```

# load mysql data and pull into neo4j

## load sample mysql data

- **purpose for loading sample data**
  - this section deals with loading some sample data inside the mysql database setup in the previous sections
  - this data will then be imported inside neo4j using the connection setup in the previous section
  - then we will be able to verify if changes in mysql are replicated inside neo4j and then is our AI able to RAG this data
- **about the sample database**
  - the [Sakila database](https://dev.mysql.com/doc/sakila/en/sakila-introduction.html) simulates a DVD rental store, including information about movies, actors, and customers
  - it contains tables for films, actors, and film categories, as well as rental transactions and payment records
  - customer and staff details, along with store locations, are also included
  - the database tracks which films are rented, their rental history, and associated payments
  - it serves as a practical example for learning SQL queries and database management
- **download and unpack**
  - download the database files from [here](https://dev.mysql.com/doc/index-other.html)
  - unzip the file and place the artefacts inside the [plugins folder](/plugins)
  - copy these files inside the mysql container
    - `docker cp ./plugins/sakila-schema.sql mysql-container:/sakila-schema.sql`
    - `docker cp ./plugins/sakila-data.sql mysql-container:/sakila-data.sql`
- **load the database**
  - log in to the mysql container and load the sakila database
    - `docker exec -it mysql-container mysql -u root -p`
  - use the password - `rootpassword`
  - load the sakila schema
    - `SOURCE /sakila-schema.sql;`
  - load the sakila data
    - `SOURCE /sakila-data.sql;`
- **verify the data load**

```sql
SHOW DATABASES;
USE sakila;
SHOW TABLES;
SELECT * FROM actor LIMIT 10;
```

- **grant permissions to neo4j**
  - in the next section i will be pulling data from mysql into neo4j using cypher queries
  - before doing this, i need to grant necessary privileges to the user

```sql
GRANT ALL PRIVILEGES ON sakila.* TO 'user'@'%';
FLUSH PRIVILEGES;
```

- verify the privileges are set correctly
  - `SHOW GRANTS FOR 'user'@'%';`
- **bounce**
  - bounce the containers
    - `docker-compose down`
    - `docker-compose up -d`
  - check if containers are running again
    - `docker ps`

## pull mysql data into neo4j

- **purpose**
  - in the previous sections i have setup the mysql and neo4j containers using docker-compose and also loaded some sample data inside mysql
  - in this section i want to pull the mysql data inside neo4j and setup a permenant connection so that any future changes to mysql data are replicated into neo4j
- **configure neo4j to allow apoc procedures**
  - create the [neo4j.conf file](/plugins/neo4j.conf) to include the necessary APOC configuration and place it in the plugins folder
  - these are the contents of the conf file

```conf
apoc.import.file.enabled=true
apoc.export.file.enabled=true
apoc.import.file.use_neo4j_config=true
apoc.import.file.use_system_temp_directory=false
apoc.import.file.directories=/import,/plugins
apoc.load.jdbc.allowlist=jdbc:mysql://mysql-container:3306
```

- copy this file to the neo4j container
  - `docker cp ./plugins/neo4j.conf neo4j-container:/var/lib/neo4j/conf/neo4j.conf`
- restart the neo4j container
  - `docker-compose restart neo4j`
- **create apoc procedures to load data from mysql**
  - open the Neo4j browser at `http://localhost:7474/browser/` and log in with `neo4j` & `password`
  - then run the following cypher queries to create procedures to load data from the mysql sakila database
  - note that all sakila entities will be loaded to neo4j from mysql as shown [here](https://dev.mysql.com/doc/sakila/en/sakila-structure.html)

```cypher
CALL apoc.load.driver('com.mysql.cj.jdbc.Driver');

// Load actors
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM actor') YIELD row
RETURN row;

// Load cities
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM city') YIELD row
RETURN row;

// Load countries
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM country') YIELD row
RETURN row;

// Load customers
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM customer') YIELD row
RETURN row;

// Load addresses
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM address') YIELD row
RETURN row;

// Load films
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM film') YIELD row
RETURN row;

// Load film_actor
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM film_actor') YIELD row
RETURN row;

// Load film_text
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM film_text') YIELD row
RETURN row;

// Load film_category
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM film_category') YIELD row
RETURN row;

// Load languages
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM language') YIELD row
RETURN row;

// Load categories
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM category') YIELD row
RETURN row;

// Load stores
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM store') YIELD row
RETURN row;

// Load inventories
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM inventory') YIELD row
RETURN row;

// Load rentals
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM rental') YIELD row
RETURN row;

// Load payments
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM payment') YIELD row
RETURN row;

// Load staff
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM staff') YIELD row
RETURN row;

// Load sales_by_store view
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM sales_by_store') YIELD row
RETURN row;

// Load customer_list view
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM customer_list') YIELD row
RETURN row;

// Load staff_list view
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM staff_list') YIELD row
RETURN row;

// Load film_list view
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM film_list') YIELD row
RETURN row;

// Load nicer_but_slower_film_list view
CALL apoc.load.jdbc('jdbc:mysql://user:password@mysql-container:3306/sakila', 'SELECT * FROM nicer_but_slower_film_list') YIELD row
RETURN row;
```

## verify pulled data inside neo4j

- **purpose**
  - in the previous steps we have looked at how to load sakila data into the mysql database and then also pull it inside neo4j
  - this section looks at how to explore the pulled sakila data inside neo4j
- **schema overview**
  - note that the pulled data also includes the test node that i had pulled [from mydatabase earlier](/setup/readme.md#verify-mysql-setup)
  - and plus it contains the sakila db schema
  - ![](/assets/KnowledgeGraphAI-001.png)
- **detailed schema**
  - for a detailed look at the properties and labels of nodes and relationships, you can use these queries:
  - list all labels - `CALL db.labels();`
  - list all relationship types - `CALL db.relationshipTypes();`
  - list all property keys - `CALL db.propertyKeys();`
  - ![](/assets/KnowledgeGraphAI-002.png)
  - ![](/assets/KnowledgeGraphAI-003.png)
  - ![](/assets/KnowledgeGraphAI-004.png)
- **inspect the data**
  - this will return up to 25 nodes with their properties
    - `MATCH (n) RETURN n LIMIT 25;`
    - ![](/assets/KnowledgeGraphAI-005.png)
