# syntax=docker/dockerfile:1
#
# Build stages use --platform=$BUILDPLATFORM so they always run natively on the
# host machine (e.g. arm64 on Apple Silicon). The Next.js build output is pure
# JavaScript, so the build architecture doesn't affect the final image at all.
# Only the runner stage targets the requested $TARGETPLATFORM (e.g. linux/amd64).
FROM --platform=$BUILDPLATFORM oven/bun:1-alpine AS base

# Install dependencies only when needed
FROM base AS deps
WORKDIR /app
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build the application
ENV NEXT_TELEMETRY_DISABLED=1
RUN bun run build

# Prepare the production filesystem with correct ownership for distroless nonroot
FROM alpine:latest AS perms
WORKDIR /app
RUN mkdir -p /app/.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
RUN chown -R 65532:65532 /app

# Production image - distroless Node.js 24 (nonroot)
FROM gcr.io/distroless/nodejs24-debian13:nonroot AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Copy pre-chowned application files
COPY --from=perms --chown=65532:65532 /app/ ./

USER 65532

EXPOSE 3000

CMD ["server.js"]
