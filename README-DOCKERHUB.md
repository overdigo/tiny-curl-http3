# tiny-curl-http3

Minimalist curl with HTTP/3 support built on Alpine Linux.

**GitHub:** https://github.com/overdigo/tiny-curl-http3

---

## Features

- **HTTP/3** via Cloudflare's quiche
- **HTTP/2** via nghttp2
- **Ultra-lightweight** ~20MB
- Includes **httpstat** for timing

---

## Quick Start

```bash
docker pull overdigo/tiny-curl-http3
docker run -it --rm overdigo/tiny-curl-http3 curl -V
```

---

## HTTP/3 only

```bash
docker run -it --rm overdigo/tiny-curl-http3 curl -IL https://blog.cloudflare.com --http3-only
```

---

## HTTP/2 fallback

```bash
docker run -it --rm overdigo/tiny-curl-http3 curl -IL https://blog.cloudflare.com --http3
```

---

## httpstat

```bash
docker run -it --rm overdigo/tiny-curl-http3 httpstat -ILv https://blog.cloudflare.com --http3
```

---

## License

MIT/BSD-style (same as curl and quiche)