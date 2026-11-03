# One Dockerfile for every release. RELEASE picks which server.js runs.
FROM node:22-alpine
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund
COPY common ./common
ARG RELEASE
COPY releases/${RELEASE} ./releases/${RELEASE}
ENV RELEASE=${RELEASE}
CMD ["sh", "-c", "node releases/$RELEASE/server.js"]
