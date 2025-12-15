# Coneshare Compose

This directory contains the Docker Compose setup to run **Coneshare** on your own infrastructure. Coneshare is an open-source platform that gives you a secure and private way to manage the entire lifecycle of your sensitive documents: upload, process, secure, share, and track.

For detailed application documentation, please refer to the main [Coneshare repository](https://github.com/coneshare/coneshare).

## System Resources

Coneshare must be installed on a Linux system. We recommend a recent version of Ubuntu/Debian or CentOS.

The recommended system resources are as follows:

- 2 CPU cores
- 4 GB RAM
- 20 GB of available disk space

We require at least Docker `19.03.6` and Compose `2.13.0`.

```bash
$ docker version
Client: Docker Engine - Community
 Version:           27.3.1
 ...

$ docker compose version
Docker Compose version v2.29.7
```


## Installation


### Download and Install

```bash
mkdir coneshare-server && cd coneshare-server

git clone git@github.com:coneshare/coneshare-compose.git

cd coneshare-compose/ && ./install.sh
```

Once the installation is complete, you will see output similar to the following:

```text
-----------------------------------------------------------------

You're all done! Run the following command to get Coneshare running:

  ./start.sh

-----------------------------------------------------------------
```

### Configure and Start Service

Update the `SITE_DOMAIN` and email settings in the `app.env` file. For example:

```ini
SITE_DOMAIN=https://coneshare.example.com # or http://YOUR_IP_ADDRESS:8999
```

After that, you can start the service by running the following command:

```bash
./start.sh
```

To verify that the system components are running properly, execute the following command:

```bash
./dc ps
```

You should see output similar to this:

```
ubuntu@instance-demo:~/coneshare-server/coneshare-compose$ ./dc ps
NAME                 IMAGE                            COMMAND                  SERVICE    CREATED       STATUS                 PORTS
coneshare-celery     conesharedev/coneshare:rolling   "/home/coneshare/bui…"   celery     8 hours ago   Up 8 hours (healthy)   80/tcp
coneshare-postgres   postgres:14-bullseye             "docker-entrypoint.s…"   postgres   8 hours ago   Up 8 hours (healthy)   5432/tcp
coneshare-redis      redis:6.2.14-alpine              "docker-entrypoint.s…"   redis      8 hours ago   Up 8 hours (healthy)   6379/tcp
coneshare-web        conesharedev/coneshare:rolling   "/home/coneshare/bui…"   web        8 hours ago   Up 8 hours (healthy)   0.0.0.0:8999->80/tcp, [::]:8999->80/tcp
```


### Create a Superuser

Before accessing the system for the first time, you need to create a super administrator. Please run the following command:

```bash
./dc exec web python3 manage.py createsuperuser
```

Follow the prompts to create an administrator account. Once completed, you can log in to Coneshare at `http://<your-ip-address>:8999` with these credentials.

> [!TIP]
> Default port for Coneshare server is 8999, as in the .env file.


### Stop Service

You can stop the running service containers with the following command:

```sh
./stop.sh
```

To stop and remove all service containers and networks, run the following:

```sh
./dc down
```


### Self-Hosted Reverse Proxy (Recommended for Production)

For production environments, using a reverse proxy is strongly recommended. It allows you to terminate SSL/TLS and forward client IP addresses to the application, providing a more secure and robust setup.

### Enabling HTTPS

Here is an example Nginx configuration for enabling HTTPS. This configuration assumes you are using Certbot for SSL certificates.

```nginx
upstream coneshare_web {
  # fail_timeout=0 means we always retry an upstream even if it failed
  # to return a good HTTP response

  # for a TCP configuration
  server localhost:8999 fail_timeout=0;
}

server {
    root /var/www/html;
     
    index index.html index.htm index.nginx-debian.html;
    server_name coneshare.example.com; # managed by Certbot
    client_max_body_size 1G;
    location / {
        try_files $uri @proxy_to_app;
     
    }

    location @proxy_to_app {
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header Host $http_host;
      # we don't want nginx trying to do something clever with
      # redirects, we set the Host: header above already.
      proxy_redirect off;
      proxy_pass http://coneshare_web;
    }

    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/coneshare.example.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/coneshare.example.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
server {
    if ($host = coneshare.example.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

	listen 80 ;
	listen [::]:80 ;
    server_name coneshare.example.com;
    return 404; # managed by Certbot
}
```


## Uninstall

To completely remove Coneshare and all associated data, follow these steps. **Warning: This process is irreversible and will permanently delete all application data.**

### 1. Stop and Remove Services

First, stop all running services and remove their containers and networks. From within the `coneshare-compose` directory, run:

```bash
./dc down
```

### 2. Delete Data and Configuration

Next, delete the directories for data, logs, and media, as well as the environment configuration file. These are located in the parent `coneshare-server` directory.

```bash
rm -rf ../data ../logs ../media ../app.env
```

### 3. Remove Docker Volumes

Finally, remove the persistent Docker volumes used by the database and cache.

```bash
docker volume rm coneshare-postgres
docker volume rm coneshare-redis
```
