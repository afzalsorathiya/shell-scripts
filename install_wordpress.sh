#!/bin/bash
# database="afzal_db"
# db_user="afzal"
# db_password="Afzal@3604"
# path="/var/www/html"

prefix="mydb_"
timestamp=$(date +"%Y%m%d%H%M%S")
db_name="${prefix}${timestamp}"

# Define variables
DB_USER="afzal"
DB_PASSWORD="Afzal@3604"
DB_NAME=${db_name}
WP_DIR="/var/www/html"
WP_USER="afzal"
WP_PASSWORD="Afzal@3604"
WP_EMAIL="your_email@example.com"

# Update system
sudo apt update
sudo apt upgrade -y

echo "--------------------------------------------------------------------------------"
echo " Install Apache2 webserver, MYSQL, and PHP"
echo "--------------------------------------------------------------------------------"
#sudo apt install -y apache2 mysql-server php php-mysql libapache2-mod-php php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip

# List of services to check and install if not installed
services=("apache2" "mysql-server" "php" "php-mysql" "libapache2-mod-php" "php-curl" "php-gd" "php-mbstring" "php-xml" "php-xmlrpc" "php-soap" "php-intl" "php-zip")

# Loop through the list of services
for service in "${services[@]}"; do
    if systemctl list-units --type=service --all | grep -q "$service.service"; then
        echo "$service is installed."
    else
        echo "$service is not installed. Installing..."
        sudo apt-get install -y "$service"
        if [ $? -eq 0 ]; then
            echo "$service has been successfully installed."
        else
            echo "Failed to install $service. Please check the package name or try again."
        fi
    fi
done

echo "--------------------------------------------------------------------------------"
echo " Download and Configure WORDPRESS"
echo "--------------------------------------------------------------------------------"

echo -n "Enter Sites name: "
read sites_name
site_dir="$WP_DIR/$sites_name"

# Check if WordPress is already installed
if [ -e "$WP_DIR/$sites_name" ]; then
    echo "This sites is already exists. you can choose another name."
else
    sudo mkdir -p "$WP_DIR/$sites_name"
    sudo cd "$site_dir"

    sudo wget -c https://wordpress.org/latest.tar.gz
    sudo tar -xzvf latest.tar.gz

    sudo rm latest.tar.gz
    # sudo tar -xz -C "$site_dir"
    sudo mv wordpress/* "$site_dir/"

    sudo rm /home/ubuntu/wordpress


    # Create a database and user for WordPress
    sudo mysql -u root -p  -e "CREATE DATABASE $DB_NAME;"
    sudo mysql -u root -p  -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
    sudo mysql -u root -p  -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
    sudo mysql -u root -p  -e "FLUSH PRIVILEGES;"

    sudo chown -R www-data:www-data $site_dir
    sudo chmod -R 755 $site_dir

    # Configure WordPress
    sudo cp "$site_dir"/wp-config-sample.php "$site_dir"/wp-config.php
    sudo sed -i "s/database_name_here/$DB_NAME/" "$site_dir"/wp-config.php
    sudo sed -i "s/username_here/$DB_USER/" "$site_dir"/wp-config.php
    sudo sed -i "s/password_here/$DB_PASSWORD/" "$site_dir"/wp-config.php

    sudo chown -R www-data:www-data $site_dir
    sudo chmod -R 755 $site_dir
    sudo rm $site_dir/wp-config-sample.php

    sudo rm $site_dir/index.html

    # Configure Apache virtual host
    sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/$sites_name.conf
    new_config="<VirtualHost *:80>
    DocumentRoot $site_dir
    <Directory $site_dir>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory $site_dir/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
    </VirtualHost>"
    echo "$new_config" | sudo tee /etc/apache2/sites-available/$sites_name.conf > /dev/null

# sudo sed -i "s|DocumentRoot /var/www/html|DocumentRoot $WP_DIR|" /etc/apache2/sites-available/wordpress.conf
    sudo a2ensite wordpress
    sudo a2enmod rewrite
    sudo a2dissite 000-default
    sudo service apache2 reload

    echo "WordPress has been successfully installed."
fi

    sudo service apache2 reload

   
   

#sudo mv wordpress/* $WP_DIR
# sudo chown -R www-data:www-data $WP_DIR
# sudo chmod -R 755 $WP_DIR





echo "done"






