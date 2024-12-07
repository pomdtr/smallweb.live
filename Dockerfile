FROM denoland/deno:2.1.1

# install curl
RUN apt-get update \
    && apt-get install -y curl \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Use a non-root user for better security
RUN useradd --create-home --user-group --shell $(which bash) smallweb

ARG SMALLWEB_VERSION=0.17.18

# Combine RUN commands to reduce layers and use curl instead of apt-get for installation
RUN curl -fsSL "https://install.smallweb.run?v=${SMALLWEB_VERSION}&target_dir=/usr/local/bin" | sh \
    && chmod +x /usr/local/bin/smallweb

ENV SMALLWEB_DIR=/smallweb \
    SMALLWEB_ADDR=0.0.0.0:7777
COPY --chown=smallweb:smallweb smallweb /smallweb

# www, cli and vscode directories should be readonly
RUN chmod -R u-w \
    $SMALLWEB_DIR/.smallweb \
    $SMALLWEB_DIR/www \
    $SMALLWEB_DIR/cli \
    $SMALLWEB_DIR/vscode \
    $SMALLWEB_DIR/github \
    $SMALLWEB_DIR/excalidraw/main.ts \
    $SMALLWEB_DIR/smallblog/main.ts

# Switch to non-root user
USER smallweb
ENV HOME=/home/smallweb
WORKDIR /home/smallweb

# Expose port
EXPOSE 7777

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/smallweb", "up", "--cron"]
