FROM gradle:8.10.2-jdk21 AS build
WORKDIR /src

# Copy the local structurizr-java fork and publish it to the in-image Maven Local repo
COPY structurizr-java/ structurizr-java/
RUN sed -i '/sign publishing.publications.mavenJava/d' structurizr-java/build.gradle && \
    gradle -p structurizr-java --no-daemon publishToMavenLocal

# Copy only the module we need to build the WAR
COPY structurizr-lite/ structurizr-lite/
# Swap mavenCentral and mavenLocal so that mavenLocal is checked first (for structurizr-java) && build the Spring Boot WAR
RUN sed -i '/repositories {/,/}/ { /mavenCentral()/ { N; s/\(.*\)\n\(.*\)/\2\n\1/ } }' structurizr-lite/build.gradle && \
    gradle -p structurizr-lite --no-daemon clean bootWar

# Exportable artifact stage (for docker build --output)
FROM scratch AS artifact
COPY --from=build /src/structurizr-lite/build/libs/*.war /artifacts/
