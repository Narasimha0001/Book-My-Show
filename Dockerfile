# Use a lightweight Node.js image
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN npm install

# Copy application code
COPY . .

# Expose the port your Node app uses
EXPOSE 3000

# Run the app
CMD ["npm", "start"]
