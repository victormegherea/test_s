#!/bin/bash
set -e
# Ubuntu 16.04 LTS

JAVA_PATH='openjdk-8-jre-headless'
USER_NAME='test'
USER_PASSWORD='Passw0rd'
PLUGIN_NAME=("workflow-aggregator" "envinject" "parameter-separator" "disk-usage" "rebuild"  "parameterized-trigger" \ "powershell" "job-restrictions" "CVS" "matrix-project" "git")

function install_jenkins {
# Install java
   apt-get update -y
   apt-get install $JAVA_PATH -y
# Repository key to system
   wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
# Append repository 
   sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
# Install jenkins
  apt-get update -y
  apt-get install jenkins -y
# Start jenkins 
   systemctl start jenkins
}

function config_jenkins {
# Open firewall 
   ufw allow 8080 
# Get initial password
   initial_password=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
# Get jenkins CLI
   path_to_jenkins='/var/lib/jenkins/jenkins-cli.jar'
   if  [ ! -f $path_to_jenkins ]; then 
      wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O $path_to_jenkins
   else 
      echo "CLI exist ..."
   fi  
# Jenkins version
   echo 2.0 > /var/lib/jenkins/jenkins.install.InstallUtil.lastExecVersion
# Create admin user  
   echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("'$USER_NAME'","'$USER_PASSWORD'")' |java -jar /var/lib/jenkins/jenkins-cli.jar -auth admin:$initial_password -s http://localhost:8080/ groovy =
   systemctl restart jenkins
}

function plugins_install {
  sed 's/false/true/'  /var/lib/jenkins/jenkins.CLI.xml
  systemctl restart jenkins
  sleep 20 
  systemctl status jenkins 
   
# Get private key
#   java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8080/ help -i ~/.ssh/id_rsa   
#  java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 who-am-i --username $USER_NAME --password $USER_PASSWORD
# Install plugins 
   for i in ${PLUGIN_NAME[@]};do 
      java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8080/   install-plugin $i --username $USER_NAME --password $USER_PASSWORD
   done 
  systemctl restart jenkins 
}

function main {
  
  install_jenkins 
  config_jenkins
  plugins_install
}

main

