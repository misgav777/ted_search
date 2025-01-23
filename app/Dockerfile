# Build stage
FROM maven:3.8.4-openjdk-11-slim AS build
WORKDIR /app

# Cache dependencies to speed up builds
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build the application
COPY src ./src
RUN mvn clean package -DskipTests

# Minimize the final image size by removing build-related artifacts
RUN rm -rf /root/.m2

# Run stage
FROM eclipse-temurin:11-jre-alpine
WORKDIR /app

# Copy only the built JAR file
COPY --from=build /app/target/*.jar ted-search.jar

# Add configuration files
COPY ./application-prod.properties ./application.properties

# Set a non-root user for better security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Optimize Java runtime settings for containers
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Use ENTRYPOINT for better CMD flexibility
ENTRYPOINT ["java", "-jar", "ted-search.jar"]
CMD ["--spring.config.location=./application.properties"]
