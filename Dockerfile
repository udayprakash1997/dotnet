FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

ARG vers=1.0.0.0

WORKDIR /src
#RUN curl -L https://raw.githubusercontent.com/Microsoft/artifacts-credprovider/master/helpers/installcredprovider.sh  | sh
COPY cicd.sln .
#ARG FEED_ACCESSTOKEN
#ENV DOTNET_SYSTEM_NET_HTTP_USESOCKETSHTTPHANDLER=0
#ENV NUGET_CREDENTIALPROVIDER_SESSIONTOKENCACHE_ENABLED true
#ENV VSS_NUGET_EXTERNAL_FEED_ENDPOINTS="{\"endpointCredentials\": [{\"endpoint\":\"https://pkgs.dev.azure.com/CitationUnity/_packaging/Citation.Atlas.RedisCache/nuget/v3/index.json\", \"username\":\"docker\", \"password\":\"${FEED_ACCESSTOKEN}\"}]}"

RUN mkdir "dotnet"
COPY "cicd.csproj" "dotnet"

#RUN mkdir "Unity.GraphQL.Gateway.IntegrationTests"
#COPY "Unity.GraphQL.Gateway.IntegrationTests/Unity.GraphQL.Gateway.IntegrationTests.csproj" "Unity.GraphQL.Gateway.IntegrationTests"

#RUN mkdir "Unity.GraphQL.Gateway.UnitTests"
#COPY "Unity.GraphQL.Gateway.UnitTests/Unity.GraphQL.Gateway.UnitTests.csproj" "Unity.GraphQL.Gateway.UnitTests"

# RUN dotnet restore --configfile nuget.config --disable-parallel --locked-mode "Unity.GraphQL.sln"
RUN dotnet restore --configfile nuget.config --disable-parallel --locked-mode cicd.sln
COPY . .

WORKDIR /src/dotnet

#ENV versenv=${vers}

RUN dotnet build "Unity.GraphQL.Gateway.csproj" /p:AssemblyVersion=1.0.0.0 -c Release -o /app/build

FROM build AS publish

RUN dotnet publish "Unity.GraphQL.Gateway.csproj" /p:AssemblyVersion=1.0.0.0 -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "dotnet.dll"]
