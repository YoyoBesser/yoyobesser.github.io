# Stage 1: Build the Jekyll site
FROM ruby:3.1-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY jekyll/Gemfile jekyll/Gemfile.lock* ./
RUN bundle install

COPY jekyll/ ./

RUN JEKYLL_ENV=production bundle exec jekyll build --destination /app/_site

FROM nginx:stable-alpine as server

COPY --from=build /app/_site /usr/share/nginx/html

EXPOSE 80

# Nginx default entrpoint runs the server fine
# CMD ["nginx", "-g", "daemon off;"] 