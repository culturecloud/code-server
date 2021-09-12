# Start from the code-server Debian base image
FROM codercom/code-server:latest

USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/bin/bash

# Update repository cache
RUN sudo apt-get update \
    && sudo apt-get clean

# Install unzip + rclone (support for remote filesystem)
RUN sudo apt-get install unzip -y --no-install-recommends
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

ENV PATH /home/coder/.local/bin:$PATH

# You can add custom software and dependencies for your environment below
# -----------

# Install a VS Code extension:
# Note: we use a different marketplace than VS Code. See https://github.com/cdr/code-server/blob/main/docs/FAQ.md#differences-compared-to-vs-code
RUN code-server \
    --install-extension ms-python.python \
    --install-extension golang.go \
    --install-extension esbenp.prettier-vscode \
    --install-extension mikestead.dotenv

# Install apt packages:
RUN sudo apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv

# Install PyPI modules
RUN python3 -m pip install --upgrade \
    pip \
    wheel \
    setuptools
RUN pip3 install --upgrade \
    pip-autoremove \
    pylint \
    black

# Copy files: 
# COPY deploy-container/myTool /home/coder/myTool

# -----------

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
