#!/bin/bash

set -e

echo "🔄 Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "☕ Installing Java 21 (via Azul Zulu repo)..."
sudo apt install -y wget gnupg2 software-properties-common curl unzip

# Add Azul repo for Java 21
wget -qO - https://repos.azul.com/azul-repo.key | gpg --dearmor | sudo tee /usr/share/keyrings/azul.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" | sudo tee /etc/apt/sources.list.d/zulu.list
sudo apt update
sudo apt install -y zulu21-jdk

echo "✅ Java installed:"
java -version

echo "🐘 Installing Maven 3.9.9..."
cd /opt
sudo wget https://downloads.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
sudo tar -xzf apache-maven-3.9.9-bin.tar.gz
sudo ln -s /opt/apache-maven-3.9.9 /opt/maven

# Set environment variables for Maven
cat <<EOF | sudo tee /etc/profile.d/maven.sh
export M2_HOME=/opt/maven
export PATH=\$M2_HOME/bin:\$PATH
EOF
source /etc/profile.d/maven.sh

echo "✅ Maven installed:"
mvn -version

echo "🛠️ Installing Jenkins..."
sudo apt install -y openjdk-17-jdk  # Jenkins requires Java 11 or 17
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins

echo "⚙️ Setting Jenkins to run on port 8080..."
sudo sed -i 's/^HTTP_PORT=.*/HTTP_PORT=8080/' /etc/default/jenkins
sudo systemctl daemon-reexec
sudo systemctl restart jenkins
sudo systemctl enable jenkins

echo "🌐 Jenkins is running at: http://localhost:8080"
echo "🔑 Jenkins password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo "🚀 Installing Tomcat 9.0.86 on port 8090..."
cd /opt
sudo wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.86/bin/apache-tomcat-9.0.86.tar.gz
sudo tar -xzf apache-tomcat-9.0.86.tar.gz
sudo mv apache-tomcat-9.0.86 tomcat
sudo chmod +x /opt/tomcat/bin/*.sh

# Change Tomcat port from 8080 to 8090
sudo sed -i 's/port="8080"/port="8090"/' /opt/tomcat/conf/server.xml

# Start Tomcat
/opt/tomcat/bin/startup.sh

echo "🌐 Tomcat is running at: http://localhost:8090"

echo "✅ ALL SET!"
