# ==========================================
# STAGE 1: Build Angular Frontend PWA
# ==========================================
FROM node:23-alpine AS frontend-builder
WORKDIR /app/frontend

# Kopírování závislostí a instalace
COPY satoshi-zap-frontend/package*.json ./
RUN npm ci --legacy-peer-deps

# Kopírování zbytku kódu a sestavení produkčního bundle
COPY satoshi-zap-frontend/ ./
RUN npx ng build --configuration production

# ==========================================
# STAGE 2: Node.js Backend & Serving
# ==========================================
FROM node:23-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Kopírování backend závislostí a instalace (pouze produkční)
COPY package*.json ./
RUN npm ci --only=production --legacy-peer-deps

# Kopírování backendového kódu
COPY src/ ./src/
# Vytvoření výchozí složky pro data
RUN mkdir -p /app/data

# Překopírování zkompilovaného frontendu do složky public pro statické servírování Express app
COPY --from=frontend-builder /app/frontend/dist/satoshi-zap-frontend/ /app/public/

EXPOSE 3020

CMD ["node", "src/server_exchange.js"]
