FROM tomcat:9-jre8-alpine

LABEL MAINTAINER="Siritas Dho (siritas@gmail.com)"

ENV  OC_HOME              $CATALINA_HOME/webapps/OpenClinica
ENV  OC_WS_HOME           $CATALINA_HOME/webapps/OpenClinica-ws
ENV  OC_VERSION           3.14

COPY run.sh               /run.sh
COPY OpenClinica-ws-3.14.zip /tmp/oc/OpenClinica-ws.zip
COPY OpenClinica-3.14.zip /tmp/oc/OpenClinica.zip

#### Remove default webapps
RUN  cd /tmp/oc && \
     wget -q --no-check-certificate -Opostgresql-42.2.5.jar https://jdbc.postgresql.org/download/postgresql-42.2.5.jar && \
     unzip OpenClinica-ws.zip && \
     unzip OpenClinica.zip && \
     rm -rf $CATALINA_HOME/webapps/* && \
#oc web
     mkdir $OC_HOME && cd $OC_HOME && \
     cp /tmp/oc/OpenClinica-$OC_VERSION/distribution/OpenClinica.war /tmp/oc && \
     unzip -q /tmp/oc/OpenClinica.war && cd .. && \
#oc webservice
     mkdir $OC_WS_HOME && cd $OC_WS_HOME && \
     cp /tmp/oc/OpenClinica-ws-$OC_VERSION/distribution/OpenClinica-ws.war /tmp/oc && \
     unzip -q /tmp/oc/OpenClinica-ws.war && cd .. && \
     rm -f $OC_HOME/WEB-INF/lib/postgresql-*.jar && \
     cp /tmp/oc/postgresql-42.2.5.jar $OC_HOME/WEB-INF/lib && \
#clean tmp folder
     rm -rf /tmp/oc && \
#
     mkdir $CATALINA_HOME/openclinica.data/xslt -p && \
    #  mv $CATALINA_HOME/webapps/OpenClinica/WEB-INF/lib/servlet-api-2.3.jar ../ && \
     chmod +x /*.sh

ENV  JAVA_OPTS -Xmx1280m -XX:+UseParallelGC -XX:+CMSClassUnloadingEnabled

CMD  ["/run.sh"]

