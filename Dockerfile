#FROM adoptopenjdk/openjdk8:x86_64-debianslim-jdk8u302-b08-slim
#FROM adoptopenjdk/openjdk11:x86_64-ubuntu-jdk-11.0.12_7-slim

#Both Zeppelin and Spark have unsafe Java calls that are flagged in openjdk11
#FROM  adoptopenjdk/openjdk8-openj9:x86_64-ubuntu-jdk8u-nightly-slim
FROM adoptopenjdk/openjdk8:x86_64-debian-jdk8u302-b08

#FROM adoptopenjdk/openjdk8-openj9:x86_64-alpine-jdk8u302-b08_openj9-0.27.0


ENV TEMP_BUILD_DIR="~/"

ENV Z_HOME="/opt/zeppelin" \
    Z_VERSION="0.10.0" \
    ZEPPELIN_ADDR="0.0.0.0"

ENV SPARK_VERSION="3.1.2"
ENV HADOOP_VERSION="3.2"


ENV SPARK_SLAVE_ADDR="spark://0.0.0.0:7077"

ENV SPARK_HOME="/opt/spark"
ENV PATH="${SPARK_HOME}/bin:${PATH}"

ENV PYTHON_VERSION="3.7.12"

# Update APT with latest packages
RUN apt-get update

#install build tools, we can remove later
RUN apt -y install wget build-essential

#install libs to support python3, probably don't need them all but they are small
RUN apt -y install zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev
RUN apt -y install libsqlite3-dev libreadline-dev libffi-dev curl libbz2-dev


#######################################################
# Install Python
########################################################
#https://linuxize.com/post/how-to-install-python-3-8-on-debian-10/
RUN mkdir -p ${TEMP_BUILD_DIR}/python3
WORKDIR "${TEMP_BUILD_DIR}/python3"
COPY ./bin/Python-${PYTHON_VERSION}.tar.xz ${TEMP_BUILD_DIR}/python3/
RUN cd ${TEMP_BUILD_DIR}/python3 \
    Python-${PYTHON_VERSION}.tar.xz \
    && tar -xf Python-${PYTHON_VERSION}.tar.xz \
    && cd Python-${PYTHON_VERSION} \
    && ./configure --enable-optimizations \
    && make -j 4 \
    && make install
#    && cd ${TEMP_BUILD_DIR}
#    && rm -rf python3

RUN python3 -m pip install --upgrade pip
#RUN pip3 install --upgrade --retries 100 --timeout 1800 pyspark pyarrow pyarrow-ops

#RUN curl -O https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
#RUN Anaconda3-2021.05-Linux-x86_64.sh



#############################################
# Install Spark
#############################################
RUN mkdir -p ${TEMP_BUILD_DIR}/spark
WORKDIR "${TEMP_BUILD_DIR}/spark"

COPY ./bin/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz ${TEMP_BUILD_DIR}/spark/

RUN cd ${TEMP_BUILD_DIR}/spark \
 && tar xvf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
 && mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}/ ${SPARK_HOME}

# && cd ${TEMP_BUILD_DIR} \
# && rm -rf spark

 #&& ${SPARK_HOME}/sbin/start-master.sh \
 #&& ${SPARK_HOME}/sbin/start-slave.sh ${SPARK_SLAVE_ADDR} \
 #&& ${SPARK_HOME}/bin/updatedb \

#Spark Manager runs on 4040
EXPOSE 4040

#$ sudo ss -tunelp | grep 8080
#locate start-slave.sh

# install zeppelin with python & spark interpreter
RUN mkdir -p ${Z_HOME}
WORKDIR ${Z_HOME}

COPY ./bin/zeppelin-${Z_VERSION}-bin-netinst.tgz ./zeppelin.tgz
RUN tar -zxvf zeppelin.tgz -C ./ --strip-components=1 \
&& rm zeppelin.tgz
#&& ./bin/install-interpreter.sh --name python \
#&& ./bin/install-interpreter.sh --name pyspark

# remove files to reduce image size
#RUN rm -r ./notebook/* \
	# remove all interpreters except python
#    && find ./interpreter \
#    -mindepth 1 \
#    -maxdepth 1 \
#    -type d \
#    -not -name 'python' \
#    -exec rm -rf {} \; \
#    ## remove unused jars
#    && rm ./lib/icu* \
#	&& rm ./lib/atomix* \
#	&& rm ./lib/flexmark* \
#	&& rm ./lib/bcp* \
#	&& rm ./lib/netty* \
#	&& rm ./lib/openhtmltopdf* \
#	&& rm ./lib/quartz* \
#    ## remove plugins
#    && rm -r ./plugins

# copy zeppelin config
COPY conf/interpreter.json conf/interpreter-list conf/zeppelin-site.xml ./conf/

# zeppelin runs on port 8080
EXPOSE 8080

# start zeppelin
WORKDIR ${Z_HOME}
CMD ["bin/zeppelin.sh"]
#CMD /bin/bash
