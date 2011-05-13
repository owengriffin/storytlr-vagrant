#!/bin/bash
# Installation script for Storytlr for Ubuntu Lucid 32
# This script expects to have the necessary privilages, so this invariably means root

INSTALL_DIR="/var/www"
DATABASE_NAME="storytlr"
DATABASE_USER="storytlr"
DATABASE_PASSWORD="1234"
ADMIN_USER="admin"
ADMIN_PASSWORD="1234"

if [ ! -e "/etc/apt/apt.conf.d/apt-cache-ng" ] ; then
    echo "Installing apt proxy configuration"
    echo "Acquire::http { Proxy \"http://33.33.33.30:3142\"; };" > /etc/apt/apt.conf.d/apt-cache-ng
    apt-get update
fi

# Ensure that all packages are installed without any user prompting
export DEBIAN_FRONTEND=noninteractive

# Install the necessary packages
echo "Installing debian packages"
apt-get install -yqq apache2 php5 mcrypt php5-mcrypt php5-curl php5-dev php-pear mysql-server mysql-client libmysqlclient-dev php5-mysql

# Download the latest Storytlr release
if [ ! -e "/tmp/storytlr-latest.tgz" ] ; then
    wget –quiet -O /tmp/storytlr-latest.tgz http://github.com/downloads/storytlr/core/storytlr-latest.tgz --no-check-certificate
fi

# Extract the Storytlr archive into the /var/www/ folder
if [ -e "/tmp/storytlr-latest.tgz" ] ; then
    mkdir $INSTALL_DIR -p
    cd $INSTALL_DIR
    tar --strip-components=1 -zx -f /tmp/storytlr-latest.tgz
    chown -R www-data:users $INSTALL_DIR
    chmod +w $INSTALL_DIR/protected/install
    chmod +w $INSTALL_DIR/protected/config
    chmod -R +w $INSTALL_DIR/protected/temp
    chmod -R +w $INSTALL_DIR/protected/logs
    chmod -R +w $INSTALL_DIR/protected/upload
fi

# Check that the database exists, if it doesn't create it
DATABASE_EXISTS=$(echo "show databases" | mysql -u root | grep $DATABASE_NAME | wc -l)
if [ "0" -eq "$DATABASE_EXISTS" ]; then
    echo "Database does not exist"

    echo "Creating database $DATABASE_NAME"
    mysqladmin create $DATABASE_NAME
fi

# Check to see if the database user already exists, if not create it
EXISTS=$(echo "select User from user" | mysql -u root mysql | grep $DATABASE_USER | wc -l)
if [ "0" -eq "$EXISTS" ]; then
    echo "Creating user $DATABASE_USER"
    SQL="CREATE USER '$DATABASE_USER'@'localhost' IDENTIFIED BY '$DATABASE_PASSWORD';GRANT ALL PRIVILEGES ON *.* TO '$DATABASE_USER'@'localhost' WITH GRANT OPTION;CREATE USER '$DATABASE_USER'@'%' IDENTIFIED BY '$DATABASE_PASSWORD';GRANT ALL ON $DATABASE_NAME.* TO '$DATABASE_USER'@'%';"
    printf %s "$SQL" | mysql --user=root mysql
fi
# Enable Apache2 mod_rewrite
a2enmod rewrite
# Restart Apache2 server
/etc/init.d/apache2 restart
echo "Now go to http://localhost/storytlr"
