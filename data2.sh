#!/bin/bash

# Update package repositories
apt update -y

# Install Apache web server
apt install apache2 -y

# Retrieve the instance ID from the instance metadata service (IMDS) endpoint
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Install the AWS Command Line Interface (CLI)
apt install awscli -y

# Create an HTML file with dynamic content
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>My Portfolio</title>
  <style>
    /* Add animation and styling for the text */
    @keyframes colorChange {
      0% { color: red; }
      50% { color: green; }
      100% { color: blue; }
    }
    h1 {
      animation: colorChange 2s infinite;
    }
  </style>
</head>
<body>
  <h1>Terraform Project Server 2</h1>
  <h2>Instance ID: <span style="color:green">$INSTANCE_ID</span></h2>
  <p>Rohan Mehra</p>
</body>
</html>
EOF

# Start the Apache web server
systemctl start apache2
# Enable Apache to start on system boot
systemctl enable apache2
