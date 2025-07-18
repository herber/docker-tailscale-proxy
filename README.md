# Tailscale Proxy Docker Image

This Docker image lets you expose local services from a Docker network to your Tailscale network using HAProxy and Tailscale. It acts as a TCP proxy between a service running in Docker and your private Tailscale network.

## Features

* Securely exposes Docker services via Tailscale
* Minimal configuration
* No port forwarding or firewall rules needed
* Works in Docker Compose setups
* More flexible than Tailscale's own Docker image.

## Quick Start

### Example

```yaml
version: '3.8'

services:
  my-service:
    # It doesn't even have to be a web service, any TCP service will work :)
    image: redis:7 
    networks:
      - local

  tailscale-proxy:
    image: ghcr.io/your-org/docker-tailscale-proxy:latest
    hostname: redis-proxy
    environment:
      TS_AUTHKEY: tskey-abc123
      SOURCE_ADDRESS: my-service:6379
      DESTINATION_PORT: 6379
    volumes:
      - ts_state:/var/lib/tailscale
      - /dev/net/tun:/dev/net/tun
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    networks:
      - local

networks:
  local:

volumes:
  ts_state:
```

Once running, your Redis (or whatever you have) service is available inside your Tailscale network at `redis-proxy` on port `6379`.

## Environment Variables

| Name               | Required | Description                                                                                                                           |
| ------------------ | -------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `TS_AUTHKEY`       | Yes      | A valid Tailscale auth key. Generate one at [tailscale.com](https://login.tailscale.com/admin/settings/authkeys).                     |
| `SOURCE_ADDRESS`   | Yes      | Comma-separated list of backend service addresses (e.g. `service1:80,service2:443`). These are services reachable from the container. |
| `DESTINATION_PORT` | Yes      | Port number to expose on the Tailscale network. The proxy listens on this port.                                                       |

## Capabilities and Volumes

To run the proxy container, the following are required:

* Capabilities:
  * `NET_ADMIN`
  * `SYS_MODULE`
* Volume mounts:
  * `/dev/net/tun` for the Tailscale tunnel
  * A persistent volume for `/var/lib/tailscale` to store Tailscale state across restarts

## Multi-Backend Support

You can specify multiple backend servers in `SOURCE_ADDRESS`:

```yaml
SOURCE_ADDRESS: server1:8080,server2:8080
```

HAProxy will load-balance TCP traffic between them.

## Setting a Hostname

Use the `hostname` field in your Docker Compose service definition to set the hostname advertised to Tailscale:

```yaml
hostname: my-proxy
```

Your service will then be reachable inside your Tailscale network as `my-proxy`.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

This is unofficial software and not in any way related to Tailscale.
