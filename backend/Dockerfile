# ==========================================
# Stage 1: Build the application
# ==========================================
FROM maven:3.8.8-eclipse-temurin-17-alpine AS builder
WORKDIR /app

# Copy pom.xml and source code to compile
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# ==========================================
# Stage 2: Runtime environment
# ==========================================
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Add a non-root user for security compliance
RUN addgroup -S medikiosk && adduser -S medikiosk -G medikiosk
USER medikiosk:medikiosk

# Copy the compiled JAR from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose port
EXPOSE 8081

# Start the application
ENTRYPOINT ["java", "-jar", "app.jar"]
