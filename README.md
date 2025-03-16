# Project Bolt - Cloud Run Deployment

This project is configured for continuous deployment to Google Cloud Run using Cloud Build.

## Project Structure

This is a React TypeScript application built with Vite. The application is containerized using Docker and can be automatically deployed to Cloud Run.

## Local Development

1. Install dependencies:

   ```
   npm install
   ```

2. Start the development server:

   ```
   npm run dev
   ```

3. Build the application:
   ```
   npm run build
   ```

## Docker

### Building the Docker Image Locally

```bash
docker build -t project-bolt .
```

### Running the Docker Container Locally

```bash
docker run -p 8080:8080 project-bolt
```

The application will be available at http://localhost:8080.

## Deployment to Cloud Run

This project includes a `cloudbuild.yaml` file that configures continuous deployment to Cloud Run. When you push changes to your repository, Cloud Build will automatically:

1. Build a Docker image
2. Push the image to Artifact Registry
3. Deploy the image to Cloud Run

### Prerequisites for Cloud Deployment

1. Enable the following APIs in your Google Cloud project:

   - Cloud Build API
   - Cloud Run API
   - Artifact Registry API
   - Secret Manager API

2. Set up a trigger in Cloud Build to watch your repository.

3. Grant the necessary IAM permissions to the Cloud Build service account.

4. Create secrets in Secret Manager for sensitive environment variables:
   ```bash
   gcloud secrets create supabase-anon-key --data-file=/path/to/anon-key.txt
   gcloud secrets create supabase-url --data-file=/path/to/url.txt
   ```

### Environment Variables

This project uses the following environment variables:

#### Configuration Variables

- `PORT`: The port the application listens on (automatically set by Cloud Run)
- `NODE_ENV`: Set to 'production' in the Docker container

#### Secrets

- `SUPABASE_URL`: The URL of your Supabase project
- `SUPABASE_ANON_KEY`: The anonymous API key for Supabase authentication

For local development, these are prefixed with `VITE_` in the `.env` file:

```
VITE_SUPABASE_URL=your-supabase-url
VITE_SUPABASE_ANON_KEY=your-supabase-anon-key
```

For production deployment, these are set as secrets in Cloud Run via the `cloudbuild.yaml` file.

## Important Files

- `Dockerfile`: Defines how the application is containerized
- `cloudbuild.yaml`: Configures the Cloud Build pipeline
- `.dockerignore`: Specifies files to exclude from the Docker build context
- `.env`: Contains environment variables for local development (not included in Docker build)
