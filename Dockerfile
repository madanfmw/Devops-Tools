# Use Amazon Linux 2 as the base image
FROM amazonlinux:2

# Install Nginx and clean up unnecessary files
RUN yum -y update && \
    yum -y install nginx && \
    yum clean all

# Copy the Nginx configuration file (optional, if you have a custom config)
# COPY ./nginx.conf /etc/nginx/nginx.conf

# Create a custom welcome page 

RUN echo "<!DOCTYPE html> \ 
<html> \ 
<head> \ 
    <title>Welcome Unreal-Enigne-Technologies</title> \ 
</head> \ 
<body> \ 
    <h1>Welcome Unreal-Enigne-Technologies!</h1> \ 
</body> \ 
</html>" > /usr/share/nginx/html/index.html 

# Expose port 80 for Nginx
EXPOSE 80

# Start Nginx in the foreground (daemon off)
CMD ["nginx", "-g", "daemon off;"]
