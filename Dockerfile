# Build stage
FROM node:20-alpine AS build

WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app

# Install a simple HTTP server to serve static content
RUN npm install -g serve

# Copy the build output from the build stage
COPY --from=build /app/dist /app/dist

# Set environment variables
ENV PORT=8080
ENV NODE_ENV=production

# Expose the port specified by the PORT environment variable
EXPOSE $PORT

# Start the server using the PORT environment variable
CMD serve -s dist -l $PORT 