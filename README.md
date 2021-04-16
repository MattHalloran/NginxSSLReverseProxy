# Web Server Scripts - React/Flask
Tired of keeping track of multiple development and production servers for your web project? Look no further. 

This project contains bash scripts to ease the workflow for React/Flask applications. The scripts are well-documented, allowing one to easily modify the script to match their chosen frameworks.

**Note**: This project was written for MacOS development and Ubuntu production environments. If you need to modify the scripts for different environments, feel free to submit a pull request😊

## Installation
1. git clone https://github.com/MattHalloran/WebServerScripts

## Development stack:
* Reverse proxy server - [Nginx](https://nginx.org/)
* Frontend - [React](https://reactjs.org/) (JavaScript)
* Frontend process manager - [PM2](https://pm2.keymetrics.io/)
* Backend routing - [Flask](https://flask.palletsprojects.com/) (Python)
* Backend asynchronous processes - [Redis Task Queue](https://python-rq.org/) (Python)
* Database - [PostgreSQL](https://www.postgresql.org/)
* Web server gateway interface (WSGI) server - [Gunicorn](https://www.gunicorn.org/)

## Script descriptions:
* <span>consts.sh</span> - Contains all custom variables, so other scripts can be run with minimal or node modifications
* <span>dev-start.sh</span> - Starts all development servers
* <span>certificate.sh</span> - Uses certbot to create a certificate for the production server
* <span>build.sh</span> - Readies code for production deployment
* <span>start.sh</span> - Starts all production servers
* <span>formatting.sh</span> - Prettifies console logs