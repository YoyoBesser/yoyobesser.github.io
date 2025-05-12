# Stage 1: Build the Jekyll site
FROM ruby:3.1-slim as builder

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Set working directory for the build stage
WORKDIR /app

# Copy Gemfile and install gems
COPY jekyll/Gemfile jekyll/Gemfile.lock* ./
RUN bundle install --jobs $(nproc) --retry 3

# Copy the rest of the Jekyll source code
COPY jekyll/ ./

# Build the Jekyll site
RUN bundle exec jekyll build --destination /app/_site

# Stage 2: Serve the built site with Nginx
FROM nginx:stable-alpine as server

# Copy the built site from the builder stage to the Nginx web root
COPY --from=builder /app/_site /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Nginx default command takes care of running the server
# CMD ["nginx", "-g", "daemon off;"] 