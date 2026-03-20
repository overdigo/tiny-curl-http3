# tiny-curl-http3

Minimalist curl with HTTP/3 support built on Alpine Linux.

## Features

- **HTTP/3** via Cloudflare's quiche
- **HTTP/2** via nghttp2
- **Ultra-lightweight** ~18MB
- Includes **httpstat** for request timing visualization

## Quick Start

```bash
# Pull the image
docker pull overdigo/tiny-curl-http3

# Basic HTTP/3 request
docker run --rm overdigo/tiny-curl-http3 https://cloudflare.com/

# Verbose (shows protocol)
docker run --rm overdigo/tiny-curl-http3 -v https://cloudflare.com/
```

## Using httpstat

```bash
# Basic httpstat
docker run --rm overdigo/tiny-curl-http3 httpstat https://cloudflare.com/

# With HTTP/3
docker run --rm overdigo/tiny-curl-http3 httpstat --http3 https://cloudflare.com/
```

Output:
```
  DNS   TCP   TLS  Server  TTFB   Content
  12ms  15ms  28ms    45ms   85ms     15KB
```

## HTTP Version Flags

| Flag | Description |
|------|-------------|
| `--http3` | Try HTTP/3, fall back to HTTP/2 |
| `--http3-only` | Only HTTP/3 |
| `--http2` | Only HTTP/2 |

## Verify HTTP/3 Support

```bash
docker run --rm overdigo/tiny-curl-http3 --version
# Should show: +quic +http3
```

## Alias (Recommended)

Add to your `.bashrc` or `.zshrc`:

```bash
alias curl3='docker run --rm -it overdigo/tiny-curl-http3'
alias httpstat3='docker run --rm -it overdigo/tiny-curl-http3 httpstat'
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
docker run --rm tiny-curl-http3 --version
docker run --rm tiny-curl-http3 httpstat https://cloudflare.com/

# Tag and push to Docker Hub
docker tag tiny-curl-http3:latest overdigo/tiny-curl-http3:latest
docker push overdigo/tiny-curl-http3:latest
```

### Build Arguments

You can customize versions during build:

```bash
docker build \
  --build-arg CURL_VERSION=curl-8_19_0 \
  --build-arg QUICHE_VERSION=0.24.2 \
  -t tiny-curl-http3 .
```

## Image Details

- **Base:** Alpine 3.23
- **Size:** ~18MB (compressed)
- **Architecture:** linux/amd64, linux/arm64
- **Docker Hub:** https://hub.docker.com/r/overdigo/tiny-curl-http3

## Use Cases

- Testing HTTP/3 endpoints
- Debugging HTTP/3 connections
- CI/CD pipelines
- Performance analysis with httpstat

## Credits

This project is based on the original work by [yurymuski/curl-http3](https://github.com/yurymuski/curl-http3).

## License

MIT/BSD-style (same as curl and quiche)