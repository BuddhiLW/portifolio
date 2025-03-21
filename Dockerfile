# PRODUCTION DOCKERFILE
# ---------------------

FROM node:23-alpine as builder

ENV NODE_ENV build

WORKDIR /home/node/backend

# Copy backend files directly
COPY backend/package*.json ./
COPY backend/ .

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
