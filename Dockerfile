# Base image with .NET runtime
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app

# Build image with .NET SDK
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

# Set working directory and install tools
WORKDIR /src

# Parameter for setting build version
ARG version=0.0.1

# Copy source files
COPY *.sln .
COPY ./Example.API/ ./Example.API

# Build and run tests
RUN dotnet restore 
RUN dotnet publish "Example.API/Example.API.csproj" -c Release -o /app/publish -p:Version=${version}

# Create final production image
FROM base AS final
WORKDIR /app

EXPOSE 8080
ENV ASPNETCORE_URLS=http://*:8080

ARG appUserName="app-example-api"
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home /app \
    --no-create-home \
    "${appUserName}"

RUN chown ${appUserName} /app

ARG repository_url="unknown"
ARG commit_hash="unknown"
ARG version=0.0.1

LABEL org.opencontainers.image.title="example-api" \
    org.opencontainers.image.description="Example API" \
    org.opencontainers.image.vendor="Test Org" \
    org.opencontainers.image.team="test-org" \
    org.opencontainers.image.source="${repository_url}" \
    org.opencontainers.image.version="${version}" \
    org.opencontainers.image.revision="${commit_hash}"

COPY --from=build /app/publish .
USER ${appUserName}
ENTRYPOINT ["dotnet", "Example.Api.dll"]
