FROM centos:7

RUN yum update -y \
  && yum install -y gcc gcc-c++ make openssl-devel readline-devel zlib-devel wget curl unzip vim epel-release git \
  && yum install -y vim-enhanced bash-completion net-tools bind-utils \
  && yum install -y https://repo.ius.io/ius-release-el7.rpm \
  && yum install -y python36u python36u-libs python36u-devel python36u-pip \
  && yum install -y java java-1.8.0-openjdk-devel \
  && rm -rf /var/cache/yum/* \
  && yum clean all

RUN localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LC_CTYPE "ja_JP.UTF-8"
ENV LC_NUMERIC "ja_JP.UTF-8"
ENV LC_TIME "ja_JP.UTF-8"
ENV LC_COLLATE "ja_JP.UTF-8"
ENV LC_MONETARY "ja_JP.UTF-8"
ENV LC_MESSAGES "ja_JP.UTF-8"
ENV LC_PAPER "ja_JP.UTF-8"
ENV LC_NAME "ja_JP.UTF-8"
ENV LC_ADDRESS "ja_JP.UTF-8"
ENV LC_TELEPHONE "ja_JP.UTF-8"
ENV LC_MEASUREMENT "ja_JP.UTF-8"
ENV LC_IDENTIFICATION "ja_JP.UTF-8"
ENV LC_ALL ja_JP.UTF-8

# Maven
RUN curl -OL https://archive.apache.org/dist/maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.tar.gz \
  && tar -xzvf apache-maven-3.6.2-bin.tar.gz \
  && mv apache-maven-3.6.2 /opt/ \
  && ln -s /opt/apache-maven-3.6.2 /opt/apache-maven \
  && rm apache-maven-3.6.2-bin.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk/jre/
ENV PATH $PATH:/opt/apache-maven/bin
RUN mvn -version

# spark
# RUN curl -OL https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-1.0/spark-2.4.3-bin-hadoop2.8.tgz \
#   && tar -xzvf spark-2.4.3-bin-hadoop2.8.tgz \
#   && mv spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8 /opt/ \
#   && ln -s /opt/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8 /opt/spark \
#   && rm ./spark-2.4.3-bin-hadoop2.8.tgz
# ENV SPARK_HOME /opt/spark
RUN curl -OL https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-1.0/spark-2.4.3-bin-hadoop2.8.tgz
RUN tar -xzvf spark-2.4.3-bin-hadoop2.8.tgz
RUN mv spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8 /opt/
RUN ln -s /opt/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8 /opt/spark
RUN rm ./spark-2.4.3-bin-hadoop2.8.tgz
ENV SPARK_HOME /opt/spark

# python
RUN unlink /bin/python \
  && ln -s /bin/python3 /bin/python \
  && ln -s /bin/pip3.6 /bin/pip

# Glueライブラリ取得
RUN git config --global http.sslVerify false \
  && git clone -b glue-1.0 --depth 1  https://github.com/awslabs/aws-glue-libs \
  && ln -s ${SPARK_HOME}/jars /aws-glue-libs/jarsv1 \
  && sed -i -e 's/mvn/mvn -T 4/' /aws-glue-libs/bin/glue-setup.sh \
  && ./aws-glue-libs/bin/gluepyspark

ENV PATH $PATH:/aws-glue-libs/bin/
COPY /sample /sample

WORKDIR /opt/src

ENTRYPOINT ["/bin/sh", "-c", "while :; do sleep 10; done"]