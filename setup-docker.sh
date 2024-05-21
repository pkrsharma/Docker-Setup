#!/bin/bash

#enable this for Debugging
# set -x

# Check if network name argument is provided
if [ -z "$1" ]; then
    echo "Please provide the network name as an argument." 31 47
    exit 1
fi

# Assign the network name from the argument
NETWORK_NAME="$1"

# Get the current user's home directory
HOME_DIR=$(eval echo ~${USER})

# Parent directory for languages
LANGUAGES_DIR="${HOME_DIR}/Documents/languages"

echo "Creating working directory..."
mkdir -p $LANGUAGES_DIR

echo "Grant necessary permissions to the directory"
chmod -R 777 $LANGUAGES_DIR

echo "Languages directory created at $LANGUAGES_DIR"

# Default values for MySQL
MYSQL_USER=myuser
MYSQL_PASSWORD=mypassword
MYSQL_DATABASE=mydb
MYSQL_ROOT_PASSWORD=my-secret-pw
MYSQL_HOST=mysql-container

# Parse command line arguments for MySQL details
if [ $# -gt 1 ]; then
    if [ "$2" = "-u" ] || [ "$2" = "--user" ]; then
        MYSQL_USER="$3"
    fi
    if [ "$4" = "-p" ] || [ "$4" = "--password" ]; then
        MYSQL_PASSWORD="$5"
    fi
    if [ "$6" = "-d" ] || [ "$6" = "--database" ]; then
        MYSQL_DATABASE="$7"
    fi
    if [ "$8" = "-r" ] || [ "$8" = "--root-password" ]; then
        MYSQL_ROOT_PASSWORD="$9"
    fi
    if [ "${10}" = "-h" ] || [ "${10}" = "--host" ]; then
        MYSQL_HOST="${11}"
    fi
fi

# Stop and remove containers
echo "Stopping and Removing the containers...."
docker stop php-container mysql-container mongo-container redis-container elasticsearch-container rmq-container
docker rm php-container mysql-container mongo-container redis-container elasticsearch-container rmq-container

# Create Docker network if not already created
echo "Creating Docker network: $NETWORK_NAME"
docker network ls $NETWORK_NAME
if [$? -eq 0]; then
    echo $NETWORK_NAME "docker network already exists...."
else
    docker network create $NETWORK_NAME
    echo $NETWORK_NAME "docker network created...."
fi
# Create PHP container
echo "Creating PHP container..."
docker run --rm -d --name php-container -v $LANGUAGES_DIR/php:/var/www/html -p 80:80 --network $NETWORK_NAME php:8-apache

# Set appropriate file permissions for PHP files
echo "Setting appropriate file permissions for PHP files..."
docker exec php-container chown -R www-data:www-data /var/www/html

# Create MySQL container
echo "Creating MySQL container..."
docker run --rm -d --name mysql-container -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD -e MYSQL_USER=$MYSQL_USER -e MYSQL_PASSWORD=$MYSQL_PASSWORD -e MYSQL_DATABASE=$MYSQL_DATABASE -v $LANGUAGES_DIR/mysql:/var/lib/mysql -p 3306:3306 --network $NETWORK_NAME mysql:5.6

# Create Mongo container
echo "Creating Mongo container..."
c

# Create Mongo container with username and password
#docker run --rm -d --name mongo-container -v $LANGUAGES_DIR/mongo:/data/db -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=adminpass --network $NETWORK_NAME mongo:5

# Create Redis container
echo "Creating Redis container..."
docker run --rm -d --name redis-container --hostname redis --network $NETWORK_NAME -v $LANGUAGES_DIR/redis:/data -p 6379:6379 redis:3.2.4

# Create Elasticsearch container
echo "Creating Elasticsearch container..."
docker run --rm -d --name elasticsearch-container --hostname elasticsearchdb --network $NETWORK_NAME -v $LANGUAGES_DIR/elasticsearch:/usr/share/elasticsearch/data -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" -e "xpack.security.enabled=false" elasticsearch:7.17.6

# Create RMQ container
echo "Creating RMQ container..."
docker run --rm -d --name rmq-container -p 5672:5672 -p 15672:15672 --network $NETWORK_NAME rabbitmq:3-management

echo "Container setup complete!"

echo "========================================================"

#if you setup the password above
#echo "Use mongo container: 'docker exec -it mongo-container mongo -u root -p'"
echo "Use mongo container: 'docker exec -it mongo-container mongo'"
echo "Use PHP container: 'docker exec -it php-container /bin/bash'"
echo "Use MySql container: 'docker exec -it mysql-container mysql -u root -p' Password will be: ${MYSQL_PASSWORD}"
echo "Use Redis container: 'docker exec -it redis-container redis-cli'"
echo "Elasticsearch Container: 'http://localhost:9200'"
echo "RMQ Container: 'http://localhost:15672'"
echo "Check network list: 'docker network ls'"

echo "========================================================"
