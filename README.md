# VPS Setup
The goal of this repository is to make it easy to prepare a Virtual Private Server (VPS) to server one or more websites.

Heavily inspired by [this article](https://olex.biz/2019/09/hosting-with-docker-nginx-reverse-proxy-letsencrypt/).

## Development stack  
* [Nginx](https://www.nginx.com/)
* [Docker](https://www.docker.com/)

## Getting started
1. Pick a VPS provider, such as one of the following:
    * [DigitalOcean](https://www.digitalocean.com/)
    * [Vultr](https://www.vultr.com/)
    * [Linode](https://www.linode.com/)
2. Set up VPS ([example](https://www.youtube.com/watch?v=Dwlqa6NJdMo&t=142s))
3. Connect to VPS, clone repository, and set up config files  
    a. ssh -6 root@your.vps.ip.address  
    b. git clone https://github.com/MattHalloran/WebServerScripts  
    c. cd WebServerScripts  
    d. *Edit .env-example, then rename it to .env*  
    e. *Edit conf.d files as needed*
    f. chmod +x ./scripts/*  
    g. ./scripts/fullSetup.sh  
    h. *Restart VPS and reconnect*  
    i. cd WebServerScripts && docker-compose up  
## 