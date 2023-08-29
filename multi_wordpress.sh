#!/bin/bash
echo "enter sites name"
read sites_name
WP_DIR="/var/www/html"

if [ -e "$WP_DIR/$sites_name" ]; then
    echo "This sites is already exists. you can choose another name."
else
    cd $WP_DIR
    mkdir $sites_name
    cd $sites_name
    echo "sites is create"
fi