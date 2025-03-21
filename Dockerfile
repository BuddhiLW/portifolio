# PRODUCTION DOCKERFILE
# ---------------------

FROM node:23-alpine as builder

# Install git to clone the backend repository
RUN apk add --no-cache git

ENV NODE_ENV build

WORKDIR /home/node

# Clone the backend repository
RUN git clone https://github.com/BuddhiLW/portifolio-backend.git backend

WORKDIR /home/node/backend

# Install dependencies
RUN npm install

RUN npx prisma generate \
    && npm run build \
    && npm prune --omit=dev

# ---

FROM node:23-alpine

ENV NODE_ENV production

USER node
WORKDIR /home/node

COPY --from=builder --chown=node:node /home/node/backend/package*.json ./
COPY --from=builder --chown=node:node /home/node/backend/node_modules/ ./node_modules/
COPY --from=builder --chown=node:node /home/node/backend/dist/ ./dist/
COPY --from=builder --chown=node:node /home/node/backend/prisma/ ./prisma/

CMD ["node", "dist/backend/src/main.js"]
