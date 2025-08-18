#!/bin/bash
yum update -y
yum install -y httpd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create a simple web page
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to ${environment}</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            text-align: center;
            padding: 50px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        h1 { font-size: 3em; margin-bottom: 20px; }
        p { font-size: 1.2em; }
        .info { margin: 20px 0; padding: 20px; background: rgba(255, 255, 255, 0.1); border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Deployment Successful!</h1>
        <p>Welcome to your <strong>${environment}</strong> environment</p>
        
        <div class="info">
            <h3>Instance Information</h3>
            <p><strong>Instance ID:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
            <p><strong>Availability Zone:</strong> $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>
            <p><strong>Instance Type:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-type)</p>
            <p><strong>Environment:</strong> ${environment}</p>
        </div>
        
        <div class="info">
            <h3>Health Check</h3>
            <p>✅ Web server is running</p>
            <p>✅ Infrastructure deployed successfully</p>
        </div>
    </div>
</body>
</html>
EOF

# Replace placeholders with actual values
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
INSTANCE_TYPE=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)

sed -i "s/$(curl -s http://169.254.169.254/latest/meta-data/instance-id)/$INSTANCE_ID/g" /var/www/html/index.html
sed -i "s/$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)/$AZ/g" /var/www/html/index.html
sed -i "s/$(curl -s http://169.254.169.254/latest/meta-data/instance-type)/$INSTANCE_TYPE/g" /var/www/html/index.html

# Set proper permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Install CloudWatch agent (optional)
yum install -y amazon-cloudwatch-agent