FROM debian:bookworm-slim

# Install haproxy and bash (for scripting)
RUN apt-get update && apt-get install -y --no-install-recommends haproxy bash curl ca-certificates
RUN update-ca-certificates
RUN curl -fsSL https://tailscale.com/install.sh | sh

RUN rm -rf /var/lib/apt/lists/*

# Copy cmd script
COPY cmd.sh /usr/local/bin/cmd.sh
RUN chmod +x /usr/local/bin/cmd.sh

CMD ["bash", "/usr/local/bin/cmd.sh"]
