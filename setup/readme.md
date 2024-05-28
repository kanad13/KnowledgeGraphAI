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
