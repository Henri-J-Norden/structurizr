FROM gradle:8.10.2-jdk21 AS build
WORKDIR /src

# Copy only the module we need to build the WAR
COPY structurizr-lite/ structurizr-lite/

# Build the Spring Boot WAR
RUN gradle -p structurizr-lite --no-daemon clean bootWar

# Exportable artifact stage (for docker build --output)
FROM scratch AS artifact
COPY --from=build /src/structurizr-lite/build/libs/*.war /artifacts/
