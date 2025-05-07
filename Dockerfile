# Imagen desactualizada de Node.js
FROM node:10.16.0

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar los archivos necesarios
COPY package.json .
COPY package-lock.json .

# Instalar dependencias
RUN npm install

# Copiar la aplicación
COPY . .

# Exponer el puerto
EXPOSE 3000

# Comando de inicio
CMD ["npm", "start"]