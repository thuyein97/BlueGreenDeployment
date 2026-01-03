FROM eclipse-temurin:17-jdk-alpine

LABEL org.opencontainers.image.source=https://github.com/thuyein97/BlueGreenDeployment

EXPOSE 8080
 
ENV APP_HOME=/usr/src/app

COPY target/*.jar $APP_HOME/app.jar

WORKDIR $APP_HOME

CMD ["java", "-jar", "app.jar"]
