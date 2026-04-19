# Stage 1: Build
FROM node:18-alpine AS builder
WORKDIR /app
COPY app/package*.json ./
RUN npm ci --only=production

# Stage 2: Production (small image)
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY app/ .
EXPOSE 3000
USER node
CMD ["node", "index.js"]
