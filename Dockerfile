touch /opt/docker/Dockerfile
cat <<EOT>> /opt/docker/Dockerfile
FROM openjdk
COPY spring-petclinic-2.4.2.war app/
WORKDIR app
ENTRYPOINT ["java", "-jar", "spring-petclinic-2.4.2.war", "--server.port=8085"] 
EOT

#this is populated inside ansible user data