# syntax=docker/dockerfile:1

# Build context is the frontend app (it has its own pnpm-lock.yaml):
#   docker build -f infra/docker/frontend.Dockerfile -t theseus-frontend apps/frontend

FROM node:22-alpine AS build

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Copy manifests first for dependency layer caching
COPY package.json pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile

# Copy source and build (tsc -b && vite build)
COPY . .

RUN pnpm build

FROM nginx:1.27-alpine

# SPA fallback so client-side routes work
RUN printf 'server {\n\
  listen 80;\n\
  root /usr/share/nginx/html;\n\
  index index.html;\n\
  location / {\n\
    try_files $uri $uri/ /index.html;\n\
  }\n\
}\n' > /etc/nginx/conf.d/default.conf

COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
