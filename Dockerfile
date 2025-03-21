# PRODUCTION DOCKERFILE
# ---------------------

FROM node:23-alpine as builder

# Install git for submodule checkout
RUN apk add --no-cache git

ENV NODE_ENV build

WORKDIR /home/node

# Clone the repository and submodules
COPY . .
RUN git submodule update --init --recursive

# Switch to non-root user after git operations
USER node

# Then run install in backend directory
WORKDIR /home/node/backend
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
