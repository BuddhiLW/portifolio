# PRODUCTION DOCKERFILE
# ---------------------

FROM node:23-alpine as builder

ENV NODE_ENV build

WORKDIR /home/node

# Copy the core module first
COPY core ./core

WORKDIR /home/node/backend

# Clone the backend repository
RUN apk add --no-cache git && \
    git clone https://github.com/BuddhiLW/portifolio-backend.git . && \
    rm -rf .git

# Create a tsconfig paths alias for @core
RUN echo '{ \
  "compilerOptions": { \
    "baseUrl": ".", \
    "paths": { \
      "@core": ["../core/src"], \
      "@core/*": ["../core/src/*"] \
    } \
  } \
}' > tsconfig.paths.json

# Update the main tsconfig to extend the paths config
RUN sed -i '/"extends":/c\  "extends": ["./tsconfig.paths.json"],' tsconfig.json || \
    echo '{"extends": "./tsconfig.paths.json"}' > tsconfig.json

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
COPY --from=builder --chown=node:node /home/node/core/ ./core/

CMD ["node", "dist/backend/src/main.js"]
