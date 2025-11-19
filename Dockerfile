# Create Image
FROM node:22

# Set workdir inside container
WORKDIR /myapp

# Copy your app code
COPY . .

# Install dependencies
RUN npm install

# Expose port (dynamic port from env)
# EXPOSE ${PORT:-5173}
EXPOSE 5173


# Run the development server
# CMD ["sh", "-c", "npm run dev -- --host 0.0.0.0 --port ${PORT:-5173}"]
CMD sh -c "npm run dev -- --host 0.0.0.0 --port 5173"

