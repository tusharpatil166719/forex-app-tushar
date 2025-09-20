FROM openjdk:21-jdk-slim-buster
WORKDIR /app
COPY forex-app-1.0.0.jar app.jar
COPY rates.csv rates.csv
ENTRYPOINT ["java", "-cp", "app.jar", "com.example.forex.ForexConverter", "rates.csv"]
