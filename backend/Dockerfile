FROM node:20-alpine

WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer uniquement les dépendances nécessaires en production
RUN npm install --only=production

# Copier le code de l'API
COPY index.js ./

# Port sur lequel ton API écoute
ENV PORT=3000
EXPOSE 3000

# Commande de démarrage
CMD ["npm", "start"]

