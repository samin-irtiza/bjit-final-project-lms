FROM openjdk:11
WORKDIR /app
COPY target/*.jar .
CMD ["spark-lms-0.0.1-SNAPSHOT.jar"]
ENTRYPOINT ["java", "-jar"]
