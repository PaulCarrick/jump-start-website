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
   **docker run -d -p 5432:5432 --name jump_start_server_database --volume jump_start_server_postgres_data:/var/lib/postgresql/data --volume jump_start_server_storage:/rails/storage --volume jump_start_server_user_home:/home/jump_start --network jump_start_server_network --network-alias db paulcarrick/jump-start-website-database:latest**
6) Run the Server container:\
   **docker run -d -p 3000:3000 --name jump_start_server_rails --volume jump_start_server_storage:/rails/storage --volume jump_start_server_user_home:/home/jump_start --network jump_start_server_network paulcarrick/jump-start-website-server:latest**\
\
After the conatiners are running you will have an http server available running on port 3000 locally.
The containers are designed to be used behind a reverse proxy (NGINX or Apache). You can change the parameters to use port 80 easily if you simply want an http server. If you want an ssl server you can change the port to 443 and set the mode to https (see the documentation), however there is no way to
install the certificates (which is why it's normally behind a proxy). If you need this you can use the 3rd option source code to regenerate the containers with your certificates.   

## Source Code
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
   (note there is a pre-built image on docker hub; see above).
   After setting up the .env file you can run **bin/start_server.sh**.\
   \
   You can also run the server as a service. Edit **installation/jumpstartwebsite.service**
   replacing the values in brackets with your configuration then copy the file to
   **/etc/systemd/system/** and start and enable the service.

## Documentation & Support  
Documentation is available on [jump-start-website.com](https://jump-start-website.com) to help you install and use **Jump Start Website**.

