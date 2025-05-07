# Imagen desactualizada de .NET
FROM mcr.microsoft.com/dotnet/sdk:2.1

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar los archivos necesarios
COPY *.csproj .
COPY *.sln .

# Restaurar dependencias
RUN dotnet restore

# Copiar la aplicación completa
COPY . .

# Compilar la aplicación
RUN dotnet build -c Release -o out

# Exponer el puerto
EXPOSE 5000

# Comando de inicio
CMD ["dotnet", "out/MyApp.dll"]