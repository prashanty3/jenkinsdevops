# Use a base image with an HTTP server
FROM nginx:alpine

# Copy your static files into the nginx directory
COPY . /usr/share/nginx/html

# Expose port 80
EXPOSE 80
