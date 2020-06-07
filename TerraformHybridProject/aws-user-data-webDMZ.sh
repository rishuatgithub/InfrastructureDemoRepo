#!/bin/bash

################################################################
## This script installs Apache server and starts
################################################################

yum update -y
yum install httpd -y
service httpd start
chkconfig httpd on

cd /var/www/html
echo "<html><h1>Hello World !!! Welcome to Rishu's TF Demo</h1></html>"  >  index.html