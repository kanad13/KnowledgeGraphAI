# purpose

- this page describes how to setup the local and cloud environments as summarized [here](/readme.md#sequence-of-steps)

# developer machine

## pre-requisites - developer machine

- **local machine**
  - ensure you have mac/linux/[WSL](https://learn.microsoft.com/en-us/windows/wsl/about) as your local development environment
  - you must have admin permissions on your local machine
  - this guide assumes you are using a mac
- **installed software**
  - you must have [python](https://devguide.python.org/versions/) 3.8 or later and [git](https://mirrors.edge.kernel.org/pub/software/scm/git/) 2.25 or later installed on your machine
  - plus ensure you have the latest version of [brew](https://brew.sh)

## python virtual environment

- all packages needed for running this code can be deployed inside a virtual environment
- these are the steps
  - first clone this repo locally
  - then open the folder
    - `cd KnowledgeGraphAI`
- then create a Python virtual environment
  - `python -m venv python_venv`
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

# local kubernetes

## pre-requisites - local kubernetes

- install [docker desktop](https://docs.docker.com/desktop/)
- [enable kubernetes](https://docs.docker.com/desktop/kubernetes/) in docker desktop settings

## create kubernetes configurations

- create the below configuration files
  - a namespace for the kubernetes services - namespace.yaml
  - a deployment and service for Neo4j - neo4j-deployment.yaml
  - a deployment and service for MySQL - mysql-deployment.yaml
- you can find all 3 files inside the [config folder](/config)

## apply configurations to local cluster

- open terminal and run the below commands

```sh
cd KnowledgeGraphAI
kubectl apply -f config/namespace.yaml
kubectl apply -f config/neo4j-deployment.yaml
kubectl apply -f config/mysql-deployment.yaml
```

- check the status of the pods and services

```sh
kubectl get pods -n dev-environment
kubectl get svc -n dev-environment
```

# porting to GCP

- first fulfill the pre-requisites for setting up the gke cluster as described in [gcp kubernetes engine documentation](https://cloud.google.com/kubernetes-engine/docs)
- to create the run

```sh
gcloud container clusters create my-cluster --zone us-central1-a
```

- get credentials for the cluster

```sh
gcloud container clusters get-credentials my-cluster --zone us-central1-a
```

- apply the kubernetes configurations

```sh
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/neo4j-deployment.yaml
kubectl apply -f k8s/mysql-deployment.yaml
```
