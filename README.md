# Docker Setup Script

### Description

This script sets up a development environment with multiple Docker containers, including PHP, MySQL, MongoDB, Redis, Elasticsearch, and RabbitMQ. It also creates a Docker network to allow communication between these containers.

## Prerequisites

- Docker installed on your system
- Bash shell

## Usage

1. Clone this repository or save the script to your local machine.
2. Make sure the script is executable:
   ```sh
   chmod +x setup-docker.sh

## Run the script with the required network name argument:
```
./setup-docker.sh <network-name> [options]
```

### Options

The script accepts the following optional parameters for MySQL configuration:


-u, --user: MySQL user (default: myuser)\
-p, --password: MySQL password (default: mypassword)\
-d, --database: MySQL database name (default: mydb)\
-r, --root-password: MySQL root password (default: my-secret-pw)\
-h, --host: MySQL host (default: mysql-container)\


### Example:
```
./setup-docker.sh my-network -u customuser -p custompassword -d customdb -r customrootpassword -h customhost\
```

## Script Details
### Directory Structure

The script creates a working directory for language-specific data at:

```
/YOUR_HOME_DIRECTORY/Documents/languages
```

### Container Management
Stops and removes any existing Docker containers named php-container, mysql-container, mongo-container, redis-container, elasticsearch-container, and rmq-container.
Creates a Docker network if it doesn't already exist.




