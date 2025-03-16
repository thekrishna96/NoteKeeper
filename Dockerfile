# Stage 1: Development dependencies & Build
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Install dependencies required for node-gyp
RUN apk add --no-cache python3 make g++

# Copy package files
COPY package*.json ./

# Install dependencies with specific flags for better error handling
RUN npm ci --prefer-offline --no-audit --no-optional

# Copy application files
COPY . .

# Build the application
RUN npm run build

# Stage 2: Production
FROM node:20-alpine AS runner

# Set working directory
WORKDIR /app

# Install serve package globally
RUN npm install -g serve@14.2.1

# Create non-root user for security
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Set environment variables
ENV NODE_ENV=production \
    PORT=8080

# Copy only the built files from builder
COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist

# Switch to non-root user
USER nextjs

# Expose the port
EXPOSE 8080

# Set healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:$PORT/ || exit 1

# Start the application
CMD ["serve", "-s", "dist", "-l", "8080"] 