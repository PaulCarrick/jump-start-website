# Jump Start Website

## Installing Jump Start Website
There are several options for installing **Jump Start Website**.\
\
The first option is using debain packages (apt or apt-get). This is by far the easiest as it asks you all the questions and preconfigures the install for you. This is also fairly flexiable as you can choose all the setup parameters. However, this is also the slowest as it needs to compile Ruby 3.2 for Debain 12. \
\
The next option are docker images. This is also fairly easy and it is the quickest of the three options. however this is the least flexiable as it is preconfiured and somewhat difficult to change. \
\
The final option is to install from source. This is fairly quick to load the repo but does require some work to install. If you do not need to change the code and debian doesn't work for you then you can download the repository and run the install script. If you want you can change the code (at you own risk ;) and then deploy it as you like. This is the most difficult option to use.

## Debian Package
1) Install the public key for the jump-start-website repository:\
   **curl -fsSL https://jump-start-website.com:8443/distributions/jump-start-website.gpg | sudo tee /usr/share/keyrings/jump-start-website.gpg > /dev/null**
2) Add the repository to the apt source file:\
   **echo "deb [signed-by=/usr/share/keyrings/jump-start-website.gpg] https://jump-start-website.com:8443/distributions/debian/ stable main" | sudo tee /etc/apt/sources.list.d/jump-start-website.list**
3) Install the apt package:\
   **sudo apt update**\
   **sudo apt install jump-start-website**
4) Configure/Install **Jump Start Website**\
   **sudo /usr/local/jump-start-website/installation/install**

## Docker
Ready-made images for AMD64 and ARM64 (Intel and Apple Silicon or other ARM servers) are published on GitHub and Docker Hub:

| | GitHub (GHCR) | Docker Hub |
|---|---|---|
| Web server | `ghcr.io/paulcarrick/jump-start-website-rails` | `docker.io/paulcarrick/jump-start-website-server` |
| Database | `ghcr.io/paulcarrick/jump-start-website-database` | `docker.io/paulcarrick/jump-start-website-database` |

Each release has a version tag (for example `v2.2.0`) and `latest`. You need Docker with Compose and Python 3.

1) Get `compose.yml` and `bin/docker-setup` from this repository (clone it, or download just those two files).
2) Create the private settings file (database password, secret key and the administrator's login):\
   **bin/docker-setup**
3) Add the image names to the `.env` it created (use the same version for both):\
   **JUMPSTART_RAILS_IMAGE=ghcr.io/paulcarrick/jump-start-website-rails:v2.2.0**\
   **JUMPSTART_DATABASE_IMAGE=ghcr.io/paulcarrick/jump-start-website-database:v2.2.0**
4) Download the images and start them:\
   **docker compose pull**\
   **docker compose up -d --no-build**
5) Open http://localhost:3000 and sign in with `ADMIN_EMAIL` and `ADMIN_PASSWORD` from `.env`.

The database and the uploaded files are kept in Docker volumes, so they survive restarts and upgrades. The site listens on localhost only; to put it on the Internet, set `SITE_URL` and run it behind an HTTPS reverse proxy (NGINX or Apache). See [docs/docker.md](docs/docker.md) for building the images yourself, upgrades, backups and public hosting.

## Source Code
1) Clone the repository\
   **git clone git@github.com:PaulCarrick/jump-start-website.git**
2) Change to the repository directory\
   **cd jump-start-website**
3) Configure or install
   * To install simply run: **installation/install.sh**\
   Answer the questions and **jump-start-website** will be installed.\
   \
   It can take quite a while if you need to install Ruby. Jump Start Website
   needs Ruby 4.0.7 (see `.ruby-version`), which most Linux distributions do
   not ship yet, so choose yes on the Ruby install unless you already have it.
   If you do, skip installing Ruby; it will save you a lot of time.
   * If you want to configure rather than install it is a little more difficult.\
   You need to set up a .env file in the root of the repository.\
   \
   There are two examples provided **example.env** and **docker-example.env**.
   Use **example.env** if you are running the rails app locally on the server.
   Use **docker-example.env** if you are going to build your own docker image
   (note there are pre-built images; see Docker above).
   After setting up the .env file you can run **bin/start_server.sh**.\
   \
   You can also run the server as a service. Edit **installation/jumpstartwebsite.service**
   replacing the values in brackets with your configuration then copy the file to
   **/etc/systemd/system/** and start and enable the service.

## Documentation & Support  
Documentation is available on [jump-start-website.com](https://jump-start-website.com) to help you install and use **Jump Start Website**.

