# Use Node.js 18
FROM node:18

WORKDIR /app

COPY package.json package-lock.json ./

# Install dependencies (with postcss fix)
RUN npm install postcss@8.4.21 postcss-safe-parser@6.0.0 --legacy-peer-deps
RUN npm install

COPY . .

EXPOSE 3000

# ✅ Make React dev server bind to Docker network
ENV NODE_OPTIONS=--openssl-legacy-provider
ENV PORT=3000
ENV HOST=0.0.0.0

CMD ["npm", "start"]
