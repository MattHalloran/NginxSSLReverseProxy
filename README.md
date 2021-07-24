# Nginx/LetsEncrypt Reverse Proxy
The goal of this repository is to make it easy to prepare a Virtual Private Server (VPS) to server one or more websites.

Heavily inspired by [this article](https://olex.biz/2019/09/hosting-with-docker-nginx-reverse-proxy-letsencrypt/).

![Server Architecture - from https://olex.biz/2019/09/hosting-with-docker-nginx-reverse-proxy-letsencrypt/](/images/proxy-diagram.png)

## Development stack  
| Dependency  | Purpose  |  Version  |
|---|---|---|
| [Nginx](https://www.nginx.com/)  | Reverse proxy server  |  [latest](https://hub.docker.com/layers/jwilder/nginx-proxy/latest/images/sha256-2619a7e00d8e79f6e456eae7c49de7cb2dbc1ef8c67fecbf51d09a5aa8fc1441?context=explore) |
| [Docker](https://www.docker.com/) | Container handler  |  latest  |

## Prerequisites
1. Must have a website name name, with access to its DNS settings. If you're not sure where to get started, I like using [Google Domains](https://domains.google/)
2. Must have access to a Virtual Private Server (VPS). They can be as little as $5 a month. Here are some good sites:
    * [DigitalOcean](https://m.do.co/c/eb48adcdd2cb) (Referral link)
    * [Vultr](https://www.vultr.com/)
    * [Linode](https://www.linode.com/)

## Getting started
1. Pick a VPS provider, such as one of the following:
    * [DigitalOcean](https://www.digitalocean.com/)
    * [Vultr](https://www.vultr.com/)
    * [Linode](https://www.linode.com/)
2. Set up VPS ([example](https://www.youtube.com/watch?v=Dwlqa6NJdMo&t=142s))
3. Connect to your VPS. I use an Ubuntu server with Docker pre-installed, but the setup script in this project can also set up Docker.
    `ssh -6 root@youp.vps.ip.address`
4. Clone repository  
    `git clone https://github.com/MattHalloran/WebServerScripts && cd WebServerScripts`
5. Run setup script  
    `chmod +x ./scripts/fullSetup.sh && ./scripts/fullSetup.sh`
6. Start docker  
    `sudo docker-compose up -d`


## Common commands
- Find docker container IDS: `docker ps -a`
- Check nginx configuration file (auto-generated): `docker exec <nginx-proxy-containier_id> cat /etc/nginx/conf.d/default`