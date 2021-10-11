# zeppelin

Docker zeppelin

Zeppelin 0.10.0
Spark 3.1.2
Hadoop 3.2
Python 3.7.12  Mote: Python 3.8.x was tried but ran into conflicts with PySpark compatibility
Java 1.8  Note: Java 11 was tried but has issues with reflection violations

docker cp SparkFlightConnector-1.0-SNAPSHOT-jar-with-dependencies.jar zep:/opt/spark/jars
docker cp flight-core-5.0.0-jar-with-dependencies.jar zep:/opt/spark/jars
docker cp grpc-netty-1.30.2.jar zep:/opt/spark/jars
docker cp grpc-core-1.30.2.jar zep:/opt/spark/jars
