# tiny-curl-http3

Minimalist curl with HTTP/3 support built on Alpine Linux.

---

## Features

- **HTTP/3** via Cloudflare's quiche
- **HTTP/2** via nghttp2
- **Ultra-lightweight** ~15MB
- Includes **httpstat** for request timing visualization

---

## Quick Start

```bash
# Pull the image
docker pull overdigo/tiny-curl-http3

# Basic HTTP/3 request
docker run --rm overdigo/tiny-curl-http3 https://cloudflare.com/

# Verbose (shows protocol)
docker run --rm overdigo/tiny-curl-http3 -v https://cloudflare.com/
```

---

## Using httpstat

httpstat visualizes curl request timing in a beautiful way.

### Basic httpstat

```bash
docker run --rm overdigo/tiny-curl-http3 httpstat https://cloudflare.com/
```

Output:
```
  DNS   TCP   TLS  Server  TTFB   Content
  12ms  15ms  28ms    45ms   85ms     15KB
```

### httpstat with HTTP/3

```bash
docker run --rm overdigo/tiny-curl-http3 httpstat --http3 https://cloudflare.com/
```

### httpstat with custom headers

```bash
docker run --rm overdigo/tiny-curl-http3 httpstat -H "Accept: application/json" https://api.github.com/
```

### httpstat to your own server

```bash
docker run --rm overdigo/tiny-curl-http3 httpstat https://your-server.com/
```

---

## HTTP Version Flags

| Flag | Description |
|------|-------------|
| `--http3` | Try HTTP/3, fall back to HTTP/2 |
| `--http3-only` | Only HTTP/3 |
| `--http2` | Only HTTP/2 |

### Examples

```bash
# Force HTTP/3 only
docker run --rm overdigo/tiny-curl-http3 --http3-only https://cloudflare.com/

# Use HTTP/2
docker run --rm overdigo/tiny-curl-http3 --http2 https://cloudflare.com/
```

---

## Verify HTTP/3 Support

```bash
docker run --rm overdigo/tiny-curl-http3 --version
# Should show: +quic +http3
```

---

## Alias (Recommended)

Add to your `.bashrc` or `.zshrc`:

```bash
alias curl3='docker run --rm -it overdigo/tiny-curl-http3'
alias httpstat3='docker run --rm -it overdigo/tiny-curl-http3 httpstat'
```

Then use:

```bash
curl3 -v https://cloudflare.com/
httpstat3 https://cloudflare.com/
```

---

## Use Cases

- Testing HTTP/3 endpoints
- Debugging HTTP/3 connections
- CI/CD pipelines
- Performance analysis with httpstat

---

## Image Size

~15MB (compressed)

---

## License

MIT/BSD-style (same as curl and quiche)