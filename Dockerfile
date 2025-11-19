# Use official Node image
FROM node:22

# Set workdir inside container
WORKDIR /myapp

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the app
COPY . .

# Expose Vite default port
EXPOSE 5173

# Run development server on 0.0.0.0 inside container
CMD ["sh", "-c", "npm run dev -- --host 0.0.0.0 --port 5173"]
