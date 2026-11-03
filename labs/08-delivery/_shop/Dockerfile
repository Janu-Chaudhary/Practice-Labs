FROM node:24-alpine
WORKDIR /app
COPY server.js ./
ARG RELEASE
ENV RELEASE=${RELEASE}
EXPOSE 3000
CMD ["node", "server.js"]
