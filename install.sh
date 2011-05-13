#!/bin/bash
# Installation script for Storytlr for Ubuntu Lucid 32
# Owen Griffin - May 2011
# 
# This script expects to have the necessary privilages, so this invariably means root

# TODO:
# * Allow Storytlr to be downloaded from the Git repository (done)
# * Remove default Apache2 site and create one for Storytlr
# * Write custom config.ini based on script variables
# * Set up the update script as a cron task
# * Configurable apt-cache-ng proxy
# * Automatic generation of passwords?
# * Optional command line parameters to specify variables
# * wget to download quietly

# Location of the installation folder
INSTALL_DIR="/var/www/storytlr"
# The name of the MySQL database to use
DATABASE_NAME="storytlr"
# MySQL database username
DATABASE_USER="storytlr"
# MySQL database password (change this!)
DATABASE_PASSWORD="123456"

# Administrator username
ADMIN_USER="admin"
# Administrator password (change this!)
ADMIN_PASSWORD="123456"

# Set to 1 if you want to install the latest version of storytlr
USE_GIT=1
# This should by owengriffin's clone of GitHub which contains a fix for using
# Storytlr on a server running on a different port number
GIT_REPO="https://github.com/owengriffin/core.git"

if [ ! -e "/etc/apt/apt.conf.d/apt-cache-ng" ] ; then
    echo "Installing apt proxy configuration"
    echo "Acquire::http { Proxy \"http://33.33.33.30:3142\"; };" > /etc/apt/apt.conf.d/apt-cache-ng
    apt-get update
fi

# Ensure that all packages are installed without any user prompting
export DEBIAN_FRONTEND=noninteractive

# Install the necessary packages
echo "Installing debian packages"
apt-get install -y apache2 php5 mcrypt php5-mcrypt php5-curl php5-dev php-pear mysql-server mysql-client libmysqlclient-dev php5-mysql

if [ -d $INSTALL_DIR ]; then
    echo "$INSTALL_DIR already exists, skipping download"
else
    if [ "$USE_GIT" -eq 1 ]; then
        echo "Installing Git"
        apt-get -y install git-core
        echo "Downloading latest Storytlr from $GIT_REPO"
        git clone $GIT_REPO $INSTALL_DIR
        
    else
        # Download the latest Storytlr release
        if [ ! -e "/tmp/storytlr-latest.tgz" ] ; then
            wget –-quiet -O /tmp/storytlr-latest.tgz http://github.com/downloads/storytlr/core/storytlr-latest.tgz --no-check-certificate
        fi
        # Extract the Storytlr archive into the /var/www/ folder
        mkdir $INSTALL_DIR -p
        cd $INSTALL_DIR
        tar --strip-components=1 -zx -f /tmp/storytlr-latest.tgz
    fi
fi

# Install Zend framework if it does not already exist
echo "Installing Zend framework"
if [ ! -d $INSTALL_DIR/protected/library/Zend ] ; then
    if [ ! -e /tmp/zend.tar.gz ] ; then
        wget --quiet -O /tmp/zend.tar.gz http://framework.zend.com/releases/ZendFramework-1.11.6/ZendFramework-1.11.6-minimal.tar.gz
    fi
    cd $INSTALL_DIR/protected/library
    tar -zxf /tmp/zend.tar.gz
    mv $INSTALL_DIR/protected/library/ZendFramework-1.11.6-minimal/library/Zend $INSTALL_DIR/protected/library/
fi

# Set the correct permissions for the installation folder
chmod +w $INSTALL_DIR/protected/install
chmod +w $INSTALL_DIR/protected/config
if [ ! -d $INSTALL_DIR/protected/temp ] ; then
    mkdir $INSTALL_DIR/protected/temp
fi
chmod -R +w $INSTALL_DIR/protected/temp
if [ ! -d $INSTALL_DIR/protected/logs ] ; then
    mkdir $INSTALL_DIR/protected/logs
fi
chmod -R +w $INSTALL_DIR/protected/logs
if [ ! -d $INSTALL_DIR/protected/upload ] ; then
    mkdir $INSTALL_DIR/protected/upload    
fi
chmod -R +w $INSTALL_DIR/protected/upload
chown -R www-data:users $INSTALL_DIR

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
