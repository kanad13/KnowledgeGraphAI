1. [purpose](#purpose)
2. [developer machine](#developer-machine)
   1. [pre-requisites - developer machine](#pre-requisites---developer-machine)
   2. [python virtual environment](#python-virtual-environment)
   3. [vscode devcontainer](#vscode-devcontainer)
   4. [streamlit - developer machine](#streamlit---developer-machine)
3. [install neo4j \& mysql](#install-neo4j--mysql)
   1. [setup configurations](#setup-configurations)
   2. [start compose services](#start-compose-services)
   3. [verify mysql setup](#verify-mysql-setup)
   4. [verify neo4j setup](#verify-neo4j-setup)
   5. [verify mysql \& neo4j connectivity](#verify-mysql--neo4j-connectivity)
4. [load mysql data and pull into neo4j](#load-mysql-data-and-pull-into-neo4j)
   1. [load sample mysql data](#load-sample-mysql-data)
   2. [pull mysql data into neo4j](#pull-mysql-data-into-neo4j)
   3. [explore loaded sakila data in neo4j](#explore-loaded-sakila-data-in-neo4j)
5. [pending parts](#pending-parts)
   1. [user flow](#user-flow)
   2. [streamlit frontend](#streamlit-frontend)
   3. [integrate LLM with LangChain](#integrate-llm-with-langchain)
   4. [implement query handling](#implement-query-handling)

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

## setup configurations

- create a `docker-compose.yml` file to define the services for mysql and neo4j
- place the file at the root of the repo [here](/docker-compose.yml)

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
      - ./plugins:/var/lib/neo4j/plugins
      - ./conf:/var/lib/neo4j/conf
      - ./conf/apoc.conf:/var/lib/neo4j/conf/apoc.conf

volumes:
  mysql-data:
  neo4j-data:
```

- create [apoc.conf](/conf/apoc.conf) that will later allow me to connect from neo4j to mysql
- notice the last line in the conf file - if you want to connect to a different database then you need to add those db details

```conf
apoc.import.file.enabled=true
apoc.export.file.enabled=true
apoc.import.file.use_neo4j_config=true
apoc.import.file.use_system_temp_directory=false
apoc.import.file.directories=/import,/plugins
apoc.load.jdbc.allowlist=jdbc:mysql://mysql-container:3306
apoc.jdbc.mysql.url=jdbc:mysql://mysql-container:3306/sakila?user=user&password=password
```

- create [neo4j.conf ](/conf/neo4j.conf) for neo4j specific configurations

```conf
dbms.default_listen_address=0.0.0.0
dbms.default_advertised_address=localhost
dbms.security.auth_enabled=true
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
  - place the jar inside the [plugins directory](/plugins/)
- **apoc driver**
  - download the apoc driver from [here](https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases)
  - ensure that you download the apoc version that matches your neo4j instance version as mentioned [here](https://github.com/neo4j-contrib/neo4j-apoc-procedures?tab=readme-ov-file#version-compatibility-matrix)
  - for example, i first found out my neo4j version number using
    - `docker ps` - copy the id of the neo4j container
    - `docker exec <container_id_or_name> neo4j --version`
  - the output i got was `5.20.0`
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
    - `docker cp ./sample_data/sakila-schema.sql mysql-container:/sakila-schema.sql`
    - `docker cp ./sample_data/sakila-data.sql mysql-container:/sakila-data.sql`
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
- **create apoc procedures to load data from mysql**
  - open the Neo4j browser at `http://localhost:7474/browser/` and log in with `neo4j` & `password`
  - then run the following cypher queries to create procedures to load data from the mysql sakila database
  - note that all sakila entities will be loaded to neo4j from mysql as shown [here](https://dev.mysql.com/doc/sakila/en/sakila-structure.html)

### load sakila data into neo4j

- **ensures the MySQL driver is loaded**

```cypher
CALL apoc.load.driver('com.mysql.cj.jdbc.Driver');
```

- **this query fetches and merges actor data**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT * FROM actor') YIELD row
MERGE (a:Actor {actor_id: row.actor_id})
SET a.first_name = row.first_name, a.last_name = row.last_name, a.last_update = row.last_update
```

- **this query establishes the relationship between films and categories**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT * FROM film_category') YIELD row
MERGE (f:Film {film_id: row.film_id})
MERGE (c:Category {category_id: row.category_id})
MERGE (f)-[:BELONGS_TO]->(c);
```

- **this query fetches and merges category data**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT * FROM category') YIELD row
MERGE (c:Category {category_id: row.category_id})
SET c.name = row.name, c.last_update = row.last_update;
```

- **this query fetches and merges film data**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT * FROM film') YIELD row
MERGE (f:Film {film_id: row.film_id})
SET f.title = row.title, f.description = row.description, f.release_year = row.release_year,
		f.language_id = row.language_id, f.original_language_id = row.original_language_id,
		f.rental_duration = row.rental_duration, f.rental_rate = row.rental_rate,
		f.length = row.length, f.replacement_cost = row.replacement_cost,
		f.rating = row.rating, f.special_features = row.special_features,
		f.last_update = row.last_update;
```

- **this query establishes the relationship between actors and films**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT * FROM film_actor') YIELD row
MERGE (a:Actor {actor_id: row.actor_id})
MERGE (f:Film {film_id: row.film_id})
MERGE (a)-[:ACTED_IN]->(f);
```

- **this query fetches and merges language data**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT * FROM language') YIELD row
MERGE (l:Language {language_id: row.language_id})
SET l.name = row.name, l.last_update = row.last_update;
```

- **this query fetches and merges customer data**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT * FROM customer') YIELD row
MERGE (c:Customer {customer_id: row.customer_id})
SET c.store_id = row.store_id, c.first_name = row.first_name, c.last_name = row.last_name,
		c.email = row.email, c.address_id = row.address_id, c.active = row.active,
		c.create_date = row.create_date, c.last_update = row.last_update;
```

- **this query fetches and merges address data**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT * FROM address') YIELD row
MERGE (a:Address {address_id: row.address_id})
SET a.address = row.address, a.address2 = row.address2, a.district = row.district,
		a.city_id = row.city_id, a.postal_code = row.postal_code, a.phone = row.phone,
		a.last_update = row.last_update;
```

- **this query fetches and merges city data**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT * FROM city') YIELD row
MERGE (c:City {city_id: row.city_id})
SET c.city = row.city, c.country_id = row.country_id, c.last_update = row.last_update;
```

- **this query fetches and merges country data**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT * FROM country') YIELD row
MERGE (c:Country {country_id: row.country_id})
SET c.country = row.country, c.last_update = row.last_update;
```

- **this query fetches and merges rental data**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT * FROM rental') YIELD row
MERGE (r:Rental {rental_id: row.rental_id})
SET r.rental_date = row.rental_date, r.inventory_id = row.inventory_id, r.customer_id = row.customer_id,
		r.return_date = row.return_date, r.staff_id = row.staff_id, r.last_update = row.last_update;
```

- **this query fetches and merges inventory data**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT * FROM inventory') YIELD row
MERGE (i:Inventory {inventory_id: row.inventory_id})
SET i.film_id = row.film_id, i.store_id = row.store_id, i.last_update = row.last_update;
```

- **this query fetches and merges payment data**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT * FROM payment') YIELD row
MERGE (p:Payment {payment_id: row.payment_id})
SET p.customer_id = row.customer_id, p.staff_id = row.staff_id, p.rental_id = row.rental_id,
		p.amount = row.amount, p.payment_date = row.payment_date, p.last_update = row.last_update;
```

- **this query fetches and merges staff data**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT * FROM staff') YIELD row
MERGE (s:Staff {staff_id: row.staff_id})
SET s.first_name = row.first_name, s.last_name = row.last_name, s.address_id = row.address_id,
		s.email = row.email, s.store_id = row.store_id, s.active = row.active, s.username = row.username,
		s.password = row.password, s.last_update = row.last_update;
```

- **this query fetches and merges store data**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT * FROM store') YIELD row
MERGE (s:Store {store_id: row.store_id})
SET s.manager_staff_id = row.manager_staff_id, s.address_id = row.address_id, s.last_update = row.last_update;
```

### establish relationship inside neo4j sakila

- **this query establishes the relationship between films and languages**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT film_id, language_id FROM film') YIELD row
MATCH (f:Film {film_id: row.film_id})
MATCH (l:Language {language_id: row.language_id})
MERGE (f)-[:IN_LANGUAGE]->(l);
```

- **this query establishes the relationship between customers and addresses**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT customer_id, address_id FROM customer') YIELD row
MATCH (c:Customer {customer_id: row.customer_id})
MATCH (a:Address {address_id: row.address_id})
MERGE (c)-[:LIVES_AT]->(a);
```

- **this query establishes the relationship between addresses and cities**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT address_id, city_id FROM address') YIELD row
MATCH (a:Address {address_id: row.address_id})
MATCH (c:City {city_id: row.city_id})
MERGE (a)-[:IN_CITY]->(c);
```

- **this query establishes the relationship between cities and countries**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT city_id, country_id FROM city') YIELD row
MATCH (c:City {city_id: row.city_id})
MATCH (co:Country {country_id: row.country_id})
MERGE (c)-[:IN_COUNTRY]->(co);
```

- **this query establishes the relationship between rentals and customers**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT rental_id, customer_id FROM rental') YIELD row
MATCH (r:Rental {rental_id: row.rental_id})
MATCH (c:Customer {customer_id: row.customer_id})
MERGE (r)-[:RENTED_BY]->(c);
```

- **this query establishes the relationship between rentals and inventories**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT rental_id, inventory_id FROM rental') YIELD row
MATCH (r:Rental {rental_id: row.rental_id})
MATCH (i:Inventory {inventory_id: row.inventory_id})
MERGE (r)-[:CONTAINS]->(i);
```

- **this query establishes the relationship between payments and customers**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT payment_id, customer_id FROM payment') YIELD row
MATCH (p:Payment {payment_id: row.payment_id})
MATCH (c:Customer {customer_id: row.customer_id})
MERGE (p)-[:MADE_BY]->(c);
```

- **this query establishes the relationship between payments and rentals**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT payment_id, rental_id FROM payment') YIELD row
MATCH (p:Payment {payment_id: row.payment_id})
MATCH (r:Rental {rental_id: row.rental_id})
MERGE (p)-[:FOR_RENTAL]->(r);
```

- **this query establishes the relationship between staff and addresses**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT s.staff_id, a.address_id FROM staff s JOIN store st ON s.store_id = st.store_id JOIN address a ON st.address_id = a.address_id') YIELD row
MATCH (s:Staff {staff_id: row.staff_id})
MATCH (a:Address {address_id: row.address_id})
MERGE (s)-[:LIVES_AT]->(a);
```

- **this query establishes the relationship between stores and addresses**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT store_id, address_id FROM store') YIELD row
MATCH (s:Store {store_id: row.store_id})
MATCH (a:Address {address_id: row.address_id})
MERGE (s)-[:LOCATED_AT]->(a);
```

- **this query establishes the relationship between stores and managers**

```cypher
CALL apoc.load.jdbc('mysql', 'SELECT store_id, manager_staff_id FROM store') YIELD row
MATCH (s:Store {store_id: row.store_id})
MATCH (m:Staff {staff_id: row.manager_staff_id})
MERGE (s)-[:MANAGED_BY]->(m);
```

## explore loaded sakila data in neo4j

- **purpose**
  - previous sections have shown how to
    - setup a neo4j and mysql containers using docker-compose
    - connect them using mysql.jar and apoc.jar
    - load sakila data into mysql
    - fetch sakila data from mysql into neo4j
  - this section looks at how to explore the pulled sakila data inside neo4j
- **complete schema and data**
  - this query will render the complete schema and the loaded data along with their relationships in neo4j inside the graph window
  - the query matches and returns all nodes and relationships in the neo4j database
  - to fetch more than 300 records, update the values in the "Graph visualization" section of the "settings" tab inside neo4j browser sidebar

```cypher
MATCH (n)-[r]->(m)
RETURN n, r, m
LIMIT 10 // modify the limit based on how many records you would like to fetch
```

- ![](/assets/KnowledgeGraphAI-001.png)

- **count the number of films an actor has acted in**

```cypher
MATCH (a:Actor {actor_id: 1})-[:ACTED_IN]->(f:Film)
RETURN a.first_name, a.last_name, COUNT(f) AS number_of_films
```

- ![](/assets/KnowledgeGraphAI-007.png)

- **distribution of films across categories**

```cypher
MATCH (f:Film)-[:BELONGS_TO]->(c:Category)
RETURN c.name AS category, COUNT(f) AS number_of_films
ORDER BY number_of_films DESC
```

- ![](/assets/KnowledgeGraphAI-008.png)

- **connection between films and their languages**

```cypher
MATCH (f:Film)-[:IN_LANGUAGE]->(l:Language)
RETURN f.title, l.name AS language
LIMIT 10;
```

- ![](/assets/KnowledgeGraphAI-009.png)

- **geographical distribution of stores, customers, and rentals**

```cypher
MATCH (s:Store)-[:LOCATED_AT]->(a:Address)-[:IN_CITY]->(c:City)-[:IN_COUNTRY]->(co:Country)
RETURN s.store_id, a.address, c.city, co.country
```

- ![](/assets/KnowledgeGraphAI-010.png)

- **network of actors based on films they have acted in together**

```cypher
MATCH (a1:Actor)-[:ACTED_IN]->(f:Film)<-[:ACTED_IN]-(a2:Actor)
RETURN a1.first_name AS actor1_first_name, a1.last_name AS actor1_last_name, a2.first_name AS actor2_first_name, a2.last_name AS actor2_last_name, f.title AS film_title
LIMIT 10;
```

- ![](/assets/KnowledgeGraphAI-011.png)

- **this query will display actors and the films they have acted in, highlighting the "ACTED_IN" relationship**

```cypher
MATCH (a:Actor)-[:ACTED_IN]->(f:Film)
RETURN a, f
LIMIT 100
```

- ![](/assets/KnowledgeGraphAI-002.png)

- **this query shows the "BELONGS_TO" relationship between films and categories**

```cypher
MATCH (f:Film)-[:BELONGS_TO]->(c:Category)
RETURN f, c
LIMIT 100
```

- ![](/assets/KnowledgeGraphAI-003.png)

- **this query highlights the "IN_LANGUAGE" relationship between films and languages**

```cypher
MATCH (f:Film)-[:IN_LANGUAGE]->(l:Language)
RETURN f, l
LIMIT 100
```

- ![](/assets/KnowledgeGraphAI-004.png)

- **this query visualizes the "LOCATED_AT" relationship for stores, and their locations down to the country level**

```cypher
MATCH (s:Store)-[:LOCATED_AT]->(a:Address)-[:IN_CITY]->(c:City)-[:IN_COUNTRY]->(co:Country)
RETURN s, a, c, co
LIMIT 100
```

- ![](/assets/KnowledgeGraphAI-005.png)

- **this query shows the network of actors who have co-starred in films, highlighting the connections between them through shared films**

```cypher
MATCH (a1:Actor)-[:ACTED_IN]->(f:Film)<-[:ACTED_IN]-(a2:Actor)
RETURN a1, f, a2
LIMIT 10
```

- ![](/assets/KnowledgeGraphAI-006.png)

# pending parts

## user flow

- this is the overall journey for the user
  - the user will ask questions from streamlit frontend to the LLM
  - the LLM reaches out to neo4j and formulates queries that will secure the necessary data
  - neo4j answers with the desired answer and LLM will provide the answer to the frontend
- see below the 3 major sections that are still pending to be developed
  - streamlit frontend
  - integrate LLM with LangChain
  - implement query handling

## streamlit frontend

- streamlit app will act as a frontend for the GenAI application
- it will connect the neo4j and LLM parts to give the ability to the user to
  - create UI components to interact with the neo4j database
  - integrate neo4j queries into the streamlit app to display data

## integrate LLM with LangChain

- use LangChain to connect the streamlit app with Llama (or OpenAI, Gemini)
- configure the LLMGraphTransformer to process and respond to user queries
- ensure secure API connections and handle authentication

## implement query handling

- allow users to input queries in natural language
- use LLMs to interpret queries and convert them into cypher queries for neo4j
- fetch the results from neo4j and display them in the streamlit app
