FROM openjdk
COPY spring-petclinic-2.4.2.war app/
COPY ./newrelic/newrelic.jar  app/
COPY ./newrelic/newrelic.yml  app/ 
ENV NEW_RELIC_APP_NAME="lington-application"
ENV NEW_RELIC_LICENSE_KEY="eu01xx824af7624c2e9de117fe224214d200NRAL"
ENV NEW_RELIC_LOG_FILE_NAME="STDOUT"
ENTRYPOINT ["java","-javaagent:/app/newrelic.jar","-jar","/app/spring-petclinic-2.4.2.war", "--server.port=8085"]

#this is populated inside ansible user data