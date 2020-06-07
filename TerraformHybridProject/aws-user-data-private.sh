#!/bin/bash

sudo yum update -y
sudo yum install wget -y 

wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm

sudo yum localinstall mysql80-community-release-el7-3.noarch.rpm -y 

sudo yum install mysql-community-server -y 

sudo systemctl start mysqld.service

sudo service mysqld status

sudo grep 'temporary password' /var/log/mysqld.log > /home/ec2-user/mysqlpass.txt


# mysql -u root -h localhost -P 3306 -p