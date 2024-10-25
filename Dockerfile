# Use Amazon Linux 2 as the base image
FROM amazonlinux

# Install Nginx and clean up unnecessary files
RUN yum -y update && \
    yum -y install nginx && \
    yum clean all && \
    
# Copy the Nginx configuration file (optional, if you have a custom config)

# Create a custom welcome page 

echo "<!DOCTYPE html> <html> <head> <title>Welcome Unreal-Engine-Technologies</title> </head> <body> <h1>Welcome Unreal-Engine-Technologies!</h1> </body> </html>" > /usr/share/nginx/html/index.html

# Expose port 80 for Nginx
EXPOSE 80

# Start Nginx in the foreground (daemon off)
CMD ["nginx", "-g", "daemon off;"]
