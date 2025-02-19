# Jump Start Website

## Installing Jump Start Website
There are several options for installing **Jump Start Website**.\
\
If you are hosting on a debian compatible server you can install
the debian package.\
\
If you prefer Docker there are docker images for both the website
and the database on dockerhub.\
\
If you are a DIY person, you can clone this repository, and use it
directly or install it from the repository.

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
- **DockerHub (containerized version):** [Jump Start Website Docker Image](https://hub.docker.com/repository/docker/paulcarrick/jump-start-website-server/tags/latest/sha256-a847743b1016adf7dd1a3ff369f032fa3a7dac97ef226924e08f5e28e5a2faa4)
1) Pull the Database image:\
   **docker pull paulcarrick/jump-start-website-database:latest**
2) Pull the Server image:\
   **docker pull paulcarrick/jump-start-website-server:latest**
3) Create the needed volumes:\
   **docker volume create jump_start_server_postgres_data** \
   **docker volume create jump_start_server_storage** \
   **docker volume create jump_start_server_user_home**
4) Create the needed network:\
   **sudo docker network create jump_start_server_network**
5) Run the Database container:\
   **docker run -d -p 5432:5432 --name jump_start_server_database --network=jump_start_server_network
 paulcarrick/jump-start-website-database:latest**
6) Run the Server container:\
   **docker run -d -p 3000:3000 --name jump_start_server_rails --network=jump_start_server_network paulcarrick/jump-start-website-server:latest**

## Source Code
- **GitHub (source code):** This repository.
1) Clone the repository\
   **git clone git@github.com:PaulCarrick/jump-start-website.git**
2) Change to the repository directory\
   **cd jump-start-website**
3) Configure or install
   * To install simply run: **installation/install.sh**\
   Answer the questions and **jump-start-website** will be installed.\
   \
   It can take quite a bit if you need to install ruby. If you are on Debian 12,
   currently you need to choose yes on the ruby install as ruby >= 3.2.0
   is not available yet. Otherwise, if you already have ruby >= 3.2.0
   skip installing ruby it will save you a lot of time.
   * If you want to configure rather than install it is a little more difficult.\
   You need to set up a .env file in the root of the repository.\
   \
   There are two examples provided **example.env** and **docker-example.env**.
   Use **example.env** if you are running the rails app locally on the server.
   Use **docker-example.env** if you are going to build your own docker image
   (note there is a pre-built image on docker hub; see above) use **docker-example.env**.\
   \
   After setting up the .env file you can run **bin/start_server.sh**.\
   \
   You can also run the server as a service. Edit **installation/jumpstartwebsite.service**
   replacing the values in brackets with your configuration then copy the file to
   **/etc/systemd/system/** and start and enable the service.

## Documentation & Support  
Documentation is available on [jump-start-website.com](https://jump-start-website.com) to help you install and use **Jump Start Website**.

