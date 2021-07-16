# VPS Setup
The goal of this repository is to make it easy to prepare a Virtual Private Server (VPS) to server one or more websites.

Heavily inspired by [this article](https://olex.biz/2019/09/hosting-with-docker-nginx-reverse-proxy-letsencrypt/).

![Server Architecture - from https://olex.biz/2019/09/hosting-with-docker-nginx-reverse-proxy-letsencrypt/](/images/proxy-diagram.png)

## Development stack  
* [Nginx](https://www.nginx.com/)
* [Docker](https://www.docker.com/)

## Getting started
1. Pick a VPS provider, such as one of the following:
    * [DigitalOcean](https://www.digitalocean.com/)
    * [Vultr](https://www.vultr.com/)
    * [Linode](https://www.linode.com/)
2. Set up VPS ([example](https://www.youtube.com/watch?v=Dwlqa6NJdMo&t=142s))
3. Connect to VPS  
    *ssh -6 root@youp.vps.ip.address*
4. Clone repository  
    *git clone https://github.com/MattHalloran/WebServerScripts && cd WebServerScripts*
5. Run setup script  
    *chmod +x ./scripts/fullSetup.sh && ./scripts/fullSetup.sh*
6. Start docker  
    *sudo docker-compose up -d*