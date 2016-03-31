### Apache Cassandra Dockerfile

Apache Cassandra Dockerfile based on srdc/java

### Base Docker Image

* [srdc/java:oraclejdk-8](https://hub.docker.com/r/srdc/java/)


### Installation
Execute either of the following:

    docker pull srdc/cassandra:3.3  (latest)    [downloads the image from Docker Hub]
    docker build -t srdc/cassandra:3.3          [builds from the local Dockerfile]


### Usage
  * Start a cassandra server instance:


    docker run --name cassandra -d srdc/cassandra:3.3

  * Connect to Cassandra from an application in another Docker container:


    docker run --name cassandra --link some-cassandra:cassandra -d app-that-uses-cassandra
  
  * Make a cluster:


    docker run --name cassandra2 -d -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' cassandra)" srdc/cassandra:3.3


    docker run --name cassandra2 -d --link cassandra:cassandra srdc/cassandra:3.3
