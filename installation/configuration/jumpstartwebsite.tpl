[Unit]
Description=Jump Start Website
After=network.target

[Service]
ExecStart="rails server -b {server_host} -p {server_port}
WorkingDirectory={install_directory}
User={owner}
Group={owner}
Restart=always

[Install]
WantedBy=multi-user.target
