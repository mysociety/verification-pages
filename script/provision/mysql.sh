#!/bin/bash

sudo apt-get install -y mysql-server mysql-client default-libmysqlclient-dev

echo "mysql-server mysql-server/root_password password ''" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password ''" | sudo debconf-set-selections

# Grant access to root MySQL user to non-sudo system users
sudo mysql -uroot -i << SQL
  DROP USER 'root'@'localhost';
  CREATE USER 'root'@'%' IDENTIFIED BY '';
  GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
  FLUSH PRIVILEGES;
SQL
