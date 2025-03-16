# Stage 1: Build environment
FROM node:20-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache python3 make g++

# Copy package files first for better layer caching
COPY package*.json ./

# Install dependencies
RUN npm ci

# Create necessary directories
RUN mkdir -p /app/public

# Copy TypeScript and Vite configurations
COPY tsconfig*.json ./
COPY vite.config.ts ./

# Create TypeScript configuration files if they don't exist
RUN echo '{\
    "extends": "./tsconfig.json",\
    "compilerOptions": {\
      "composite": true,\
      "module": "ESNext",\
      "moduleResolution": "bundler",\
      "allowImportingTsExtensions": true\
    },\
    "include": ["src/**/*.ts", "src/**/*.tsx"]\
  }' > tsconfig.app.json && \
  echo '{\
    "compilerOptions": {\
      "composite": true,\
      "module": "ESNext",\
      "moduleResolution": "bundler",\
      "allowSyntheticDefaultImports": true\
    },\
    "include": ["vite.config.ts"]\
  }' > tsconfig.node.json

# Copy source code and static files
COPY src/ ./src/
COPY index.html ./

# Build the application
RUN npm run build

# Stage 2: Production environment
FROM node:20-alpine AS runner

# Set NODE_ENV
ENV NODE_ENV=production

# Create a non-root user for security
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 appuser && \
    mkdir -p /app && \
    chown -R appuser:nodejs /app

WORKDIR /app

# Install a simple web server to serve static content
RUN npm install -g serve@14

# Copy the built application from builder stage
COPY --from=builder --chown=appuser:nodejs /app/dist/ /app/dist/

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -q --spider http://localhost:8080/ || exit 1

# Switch to non-root user
USER appuser

# Expose the port the app will run on
ENV PORT=8080
EXPOSE 8080

# Start the application with serve
CMD ["serve", "-s", "dist", "-l", "8080"]