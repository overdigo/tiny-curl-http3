# tiny-curl-http3

Minimalist curl with HTTP/3 support built on Alpine Linux.

## Features

- **HTTP/3** via Cloudflare's quiche
- **HTTP/2** via nghttp2
- **Ultra-lightweight** ~20MB
- Production-ready HTTP client
- For linux/**amd64** and linux/**arm64**

## Quick Start

```bash
# Pull the image
  docker pull overdigo/tiny-curl-http3
# show version
  docker run -it --rm overdigo/tiny-curl-http3 curl -V
```

## Basic HTTP/3 request

```bash
  docker run -it --rm overdigo/tiny-curl-http3 curl -IL --http3-only https://blog.cloudflare.com
```

## Verbose (shows protocol)

```bash
  docker run -it --rm overdigo/tiny-curl-http3 curl -ILv --http3-only https://blog.cloudflare.com
```

## Ignore SSL certificate

```bash
  docker run -it --rm overdigo/tiny-curl-http3 curl -ILk --http3-only https://blog.cloudflare.com
```

## HTTP Version Flags

| Flag | Description |
|------|-------------|
| `--http3` | Try HTTP/3, fall back to HTTP/2 |
| `--http3-only` | Only HTTP/3 |
| `--http2` | Only HTTP/2 |

## Examples

### HTTP/2 fallback
```bash
  docker run --rm overdigo/tiny-curl-http3 curl -IL --http3 https://blog.cloudflare.com
```

### Test host nginx with http3
```bash
  docker run --rm --add-host=host.docker.internal:host-gateway overdigo/tiny-curl-http3 curl --no-progress-meter -kIL --http3-only https://host.docker.internal
```

## Alias (Recommended)

Add to your `.bashrc` or `.zshrc`:

```bash
  alias curl3='docker run --rm -it overdigo/tiny-curl-http3 curl'
```

Then use:

```bash
  curl3 -v https://cloudflare.com/
```

---

## Build from Source

### Versions Used

| Component | Version |
|-----------|---------|
| Alpine Linux | 3.23 |
| curl | 8.19.0 |
| quiche | 0.24.2 |
| nghttp2 | 1.68.0 |
| Rust | stable |

### Build Commands

```bash
# Clone this repository
git clone https://github.com/overdigo/tiny-curl-http3.git
cd tiny-curl-http3

# Build the image
docker build -t tiny-curl-http3 .

# Test locally
docker run --rm tiny-curl-http3 curl -V

# Tag and push to Docker Hub
docker tag tiny-curl-http3:latest overdigo/tiny-curl-http3:latest
docker push overdigo/tiny-curl-http3:latest
```

### Build Arguments

Customize versions during build:

```bash
docker build \
  --build-arg CURL_VERSION=curl-8_19_0 \
  --build-arg QUICHE_VERSION=0.24.2 \
  -t tiny-curl-http3 .
```

## Image Details

- **Base:** Alpine 3.23
- **Size:** ~20MB or 13MB(compressed)
- **Architecture:** linux/amd64, linux/arm64
- **Docker Hub:** https://hub.docker.com/r/overdigo/tiny-curl-http3

## Use Cases

- Testing HTTP/3 endpoints
- Debugging HTTP/3 connections
- CI/CD pipelines
- Lightweight HTTP client in containers

## Credits

This project is based on the original work by [yurymuski/curl-http3](https://github.com/yurymuski/curl-http3).

## License

MIT/BSD-style (same as curl and quiche)
