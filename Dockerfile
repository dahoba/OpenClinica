FROM maven:3.6-alpine as builder
#FROM maven:3.6-amazoncorretto-8 as builder

LABEL MAINTAINER="Siritas Dho (siritas@gmail.com)"

ENV JAVA_OPTS=""
ENV MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

RUN mkdir -p /usr/src/openclinica
WORKDIR /usr/src/openclinica

COPY pom.xml .
COPY core/pom.xml core/pom.xml
COPY web/pom.xml web/pom.xml
COPY ws/pom.xml ws/pom.xml
RUN mvn -B --fail-never verify clean

COPY core/src core/src
COPY web/src web/src
COPY ws/src ws/src
RUN mvn -B -DskipTests verify

## second steps deploy
FROM tomcat:7-jre8-alpine

ENV  OC_HOME              $CATALINA_HOME/webapps/OpenClinica
ENV  OC_WS_HOME           $CATALINA_HOME/webapps/OpenClinica-ws
ENV  OC_VERSION           3.14

COPY docker/run.sh               /run.sh
COPY --from=builder /usr/src/openclinica/web/target/OpenClinica-web-3.14.war /tmp/oc/OpenClinica.war
COPY --from=builder /usr/src/openclinica/ws/target/OpenClinica-ws-3.14.war /tmp/oc/OpenClinica-ws.war
ADD https://jdbc.postgresql.org/download/postgresql-42.2.5.jar /tmp/oc/postgresql-42.2.5.jar

#### Remove default webapps
RUN  cd /tmp/oc && \
     rm -rf $CATALINA_HOME/webapps/* && \
     mkdir -p $OC_HOME && cd $OC_HOME && pwd && cd && \
     mkdir -p $OC_WS_HOME && cd $OC_WS_HOME && pwd  && cd && \
     unzip /tmp/oc/OpenClinica.war -qd $OC_HOME && \
     unzip /tmp/oc/OpenClinica-ws.war -qd $OC_WS_HOME && \
     cp /tmp/oc/postgresql-42.2.5.jar $OC_HOME/WEB-INF/lib/ && \
#clean tmp folder
     rm -rf /tmp/oc && \
     mkdir $CATALINA_HOME/openclinica.data/xslt -p && \
     chmod +x /*.sh

ENV  JAVA_OPTS -Xmx1280m -XX:+UseParallelGC -XX:+CMSClassUnloadingEnabled

CMD  ["/run.sh"]

