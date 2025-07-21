set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

apt update
apt install -y docker.io docker-compose

# # Apt tools
curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      dotnet9 \
      nodejs \
      libgdiplus \
      build-essential \
      bc \
      ffmpeg \
      zip \
      unzip \
      tar \
      gzip \
      iputils-ping \
      net-tools \
      git \
      jq \
      shellcheck && \
#     rm -rf /var/lib/apt/lists/*

# .NET Global Tools
dotnet tool install JetBrains.ReSharper.GlobalTools --global --add-source https://nuget.aiursoft.cn/v3/index.json -v d || echo 'JB already installed.' && \
dotnet tool install dotnet-reportgenerator-globaltool --global --add-source https://nuget.aiursoft.cn/v3/index.json -v d || echo 'ReportGenerator already installed.'

# Node.js Global Tools
npm config set registry https://npm.aiursoft.cn && \
npm install -g typescript ts-node npm yarn --loglevel verbose

echo "fs.inotify.max_user_instances=524288" >> /etc/sysctl.conf && \
echo "fs.inotify.max_user_watches=524288" >> /etc/sysctl.conf && \
echo "fs.inotify.max_queued_events=524288" >> /etc/sysctl.conf && \
sysctl -p

# # Replace ${arch} with any of the supported architectures, e.g. amd64, arm, arm64
# # A full list of architectures can be found here https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/index.html
# # curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/deb/gitlab-runner-helper-images.deb"
# # curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/deb/gitlab-runner_${arch}.deb"

# Install GitLab Runner
curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/deb/gitlab-runner-helper-images.deb" && \
curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/deb/gitlab-runner_amd64.deb" && \
dpkg -i gitlab-runner-helper-images.deb && \
dpkg -i gitlab-runner_amd64.deb && \
rm -rf gitlab-runner-helper-images.deb gitlab-runner_amd64.deb

# Enable docker in docker
usermod -aG docker root && \
usermod -aG systemd-journal gitlab-runner && \
usermod -aG docker gitlab-runner && \
usermod -aG sudo gitlab-runner

chown gitlab-runner:gitlab-runner -Rv /home/gitlab-runner
chown gitlab-runner:gitlab-runner -Rv /etc/gitlab-runner

mkdir /home/gitlab-runner/.gitlab-runner
sudo cp /etc/gitlab-runner/config.toml /home/gitlab-runner/.gitlab-runner/config.toml

echo "" > /etc/gitlab-runner/.secret
echo "https://gitlab.aiursoft.cn" > /etc/gitlab-runner/.url

cat << EOF > /usr/local/bin/runner-start.sh
#!/usr/bin/env bash
gitlab-runner register \
    --non-interactive \
    --url "\$(cat /etc/gitlab-runner/.url)" \
    --token "\$(cat /etc/gitlab-runner/.secret)" \
    --executor "shell" \
    --custom_build_dir_enabled=true

rm -f /etc/gitlab-runner/.secret

gitlab-runner run --user=gitlab-runner --working-directory=/home/gitlab-runner
EOF
chmod +x /usr/local/bin/runner-start.sh

cat << EOF > /etc/systemd/system/gitlab-runner.service
[Unit]
Description=GitLab Runner
After=docker.service
Requires=docker.service

[Service]
Type=simple
ExecStart=/usr/local/bin/runner-start.sh
Restart=always
User=gitlab-runner
Group=gitlab-runner
WorkingDirectory=/home/gitlab-runner

[Install]
WantedBy=multi-user.target
EOF
systemctl enable gitlab-runner.service

# Disable sleep
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target