# Nginx/LetsEncrypt Reverse Proxy
The goal of this repository is to make it easy to [reverse proxy](https://en.wikipedia.org/wiki/Reverse_proxy) one or more website services on a Virtual Private Server (VPS). **Note: Services must be started with Docker.**

[Here](https://github.com/MattHalloran/NLN) is a project that uses this.

Heavily inspired by [this article](https://olex.biz/2019/09/hosting-with-docker-nginx-reverse-proxy-letsencrypt/). If you're looking for someone to thank, it is them!

![Server Architecture - from https://olex.biz/2019/09/hosting-with-docker-nginx-reverse-proxy-letsencrypt/](/images/proxy-diagram.png)

## Development stack  
| Dependency  | Purpose  |  Version  |
|---|---|---|
| [Nginx](https://www.nginx.com/)  | Reverse proxy server  |  [latest](https://hub.docker.com/layers/jwilder/nginx-proxy/latest/images/sha256-2619a7e00d8e79f6e456eae7c49de7cb2dbc1ef8c67fecbf51d09a5aa8fc1441?context=explore) |
| [Docker](https://www.docker.com/) | Container handler  |  latest  |

## Prerequisites
1. Must have a website name, with access to its DNS settings. If you're not sure where to get started, I like using [Google Domains](https://domains.google/).
2. Must have access to a Virtual Private Server (VPS). They can be as little as $5 a month. Here are some good sites:
    * [DigitalOcean](https://m.do.co/c/eb48adcdd2cb) (Referral link)
    * [Vultr](https://www.vultr.com/)
    * [Linode](https://www.linode.com/)
3. Must have Dockerfiles or docker-compose files to start your website's services. Each service that interfaces with Nginx (i.e. is connected to with a port) can be configured with the following environment variables:  
    - *VIRTUAL_HOST* - the website's name(s), separated by a comma with no spaces (e.g. `examplesite.com,www.examplesite.com`)
    - *VIRTUAL_PORT* - the container's port
    - *LETSENCRYPT_HOST* - website name used by LetsEncrypt. Most likely the same as *VIRTUAL_HOST*
    - *LETSENCRYPT_EMAIL* - the email address to be associated with the LetsEncrypt process

## Getting started
1. Set up VPS ([example](https://www.youtube.com/watch?v=Dwlqa6NJdMo&t=142s)).
2. Edit DNS settings to point to the VPS. Here is an example:  
   | Host Name  | Type  |  TTL  |  Data  |
   |---|---|---|---|
   | `examplesite.com`  | A  |  1 hour | `your.vps.ip.address` |
   | `www.examplesite.com` | A  |  1 hour  | `your.vps.ip.address` |
3. Connect to your VPS. I use an Ubuntu server with Docker pre-installed, but the script in this repo can also set up Docker:
    `ssh -6 root@your.vps.ip.address`
4. Clone repository:  
    `git clone https://github.com/MattHalloran/NginxSSLReverseProxy && cd NginxSSLReverseProxy`
5. Run setup script:  
    `chmod +x ./scripts/fullSetup.sh && ./scripts/fullSetup.sh`
6. Start docker:  
    `sudo docker-compose up -d`


## Common commands
- Find docker container IDS: `docker ps -a`
- Check nginx configuration file (auto-generated): `docker exec <nginx-proxy-containier_id> cat /etc/nginx/conf.d/default.conf`


## Custom proxy
Custom proxy configurations can be put in the `my_proxy.conf` file. By default, this only contains one line: `client_max_body_size 100m;`. This raises the maximum payload size for uploading files. This is useful if you'd like users to have the ability to upload multiple images in one request, for example.

If you are not using custom configurations, you can remove the docker-compose line `- ./my_proxy.conf:/etc/nginx/conf.d/my_proxy.conf:ro`.
