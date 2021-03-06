FROM debian:stable-slim

WORKDIR /opt

RUN mkdir -p /usr/share/man/man1 /usr/share/man/man7 && \
    echo "install base packages" && \
    apt-get update && apt-get install -y wget curl jq git docker tar apt-transport-https ca-certificates gnupg2 software-properties-common build-essential netcat vim && \
    echo "===============================================================" && \
    echo "install OpenJDK XX" && \
    wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.6%2B10/OpenJDK11U-jdk_x64_linux_hotspot_11.0.6_10.tar.gz -P /tmp && \
    tar -xvzf /tmp/OpenJDK11U-*.tar.gz -C /usr/lib && mv /usr/lib/jdk-* /usr/lib/jdk && \
    export PATH="$PATH:/usr/lib/jdk/bin" && \
    export JAVA_HOME="/usr/lib/jdk" && \
    java -version && \
    echo "===============================================================" && \
    echo "add repository for docker" && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    apt-key fingerprint 0EBFCD88 && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    echo "===============================================================" && \
    echo "add repository for yarn" && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    echo "===============================================================" && \
    echo "add repository for nodejs" && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    echo "===============================================================" && \
    echo "install applications" && \
    apt-get update && apt-get install -y \
        docker-ce \
        nodejs \
        yarn \
        postgresql \
        apache2-utils \
        redis-server && \
    echo "===============================================================" && \
    echo "install npm packages" && \
    npm install -g n && \
    n lts && \
    yarn global add wait-port

RUN echo "===============================================================" && \
    echo "install minio" && \
    mkdir -p /opt/minio && \
    wget https://dl.minio.io/server/minio/release/linux-amd64/minio -P /opt/minio && \
    chmod +x /opt/minio/minio 
    
RUN echo "===============================================================" && \
    echo "install kafka" && \
    wget http://apache.mirror.anlx.net/kafka/2.2.0/kafka_2.12-2.2.0.tgz -P /tmp && \
    tar -xzf /tmp/kafka_2.12-2.2.0.tgz && \
    ln -s kafka_* kafka
    
RUN echo "===============================================================" && \
    echo "install mongodb" && \
    wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-4.0.5.tgz -P /tmp && \
    tar -xzf /tmp/mongodb-linux-x86_64-4.0.5.tgz && \
    ln -s "mongodb-linux-x86_64-4.0.5" mongodb
    
RUN echo "===============================================================" && \
    echo "install wiremock" && \
    wget https://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-standalone/2.26.3/wiremock-standalone-2.26.3.jar -P /opt && \
    ln -s wiremock-* wiremock.jar && \
    chmod +x /opt/wiremock.jar

RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64]  http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list && \
    apt-get -y update && \
    apt-get -y install unzip google-chrome-stable && \
    wget https://chromedriver.storage.googleapis.com/79.0.3945.36/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip && \
    mv chromedriver /usr/bin/chromedriver && \
    chown root:root /usr/bin/chromedriver && \
    chmod +x /usr/bin/chromedriver

USER postgres
RUN /etc/init.d/postgresql start && \
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" && \
    createdb -O docker docker && \
    exit && \
    /etc/init.d/postgresql stop
USER root

RUN echo "===============================================================" && \
    echo "install Maven" && \
    apt install -y maven && \
    mvn -v

RUN echo "===============================================================" && \
    echo "install Gradle" && \
    wget https://services.gradle.org/distributions/gradle-5.6.4-bin.zip -P /tmp && \
    unzip -d /opt /tmp/gradle-*.zip && \
    mv /opt/gradle-* /opt/gradle && \
    export PATH="$PATH:/opt/gradle/bin" && \
    gradle -v

ENV PATH="${PATH}:/usr/lib/jdk/bin:/opt/gradle/bin"
ENV JAVA_HOME="/usr/lib/jdk"

RUN rm -rf /tmp/*
