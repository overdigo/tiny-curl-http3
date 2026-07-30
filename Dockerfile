ARG ALPINE_VERSION=3.24
FROM alpine:${ALPINE_VERSION} AS builder

WORKDIR /opt

# Versões das dependências
ARG CURL_VERSION=curl-8_21_0
ARG QUICHE_VERSION=0.24.9

# Instala dependências de build (sem cargo/rust do apk - usaremos rustup)
RUN apk add --no-cache \
    build-base \
    git \
    autoconf \
    automake \
    libtool \
    cmake \
    go \
    curl \
    nghttp2-dev \
    zlib-dev \
    perl \
    linux-headers \
    libpsl-dev \
    zstd-dev \
    brotli-dev \
    pkgconfig

# Instala Rust via rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --default-toolchain stable
ENV PATH="/root/.cargo/bin:$PATH"
ENV CARGO_HOME="/root/.cargo"

# Clone do quiche com submódulos recursivos
RUN git clone --recursive https://github.com/cloudflare/quiche

# Checkout da versão e atualização dos submódulos
WORKDIR /opt/quiche
RUN git checkout $QUICHE_VERSION && \
    git submodule update --init --recursive

# Verifica se o boringssl foi clonado corretamente
RUN ls -la quiche/deps/boringssl/ && \
    test -f quiche/deps/boringssl/CMakeLists.txt || (echo "BoringSSL CMakeLists.txt não encontrado!" && exit 1)

# Build do quiche
RUN cargo build --package quiche --release --features ffi,pkg-config-meta,qlog

# Prepara bibliotecas do boringssl
RUN mkdir -p quiche/deps/boringssl/src/lib && \
    find target/release -name "libcrypto.a" -o -name "libssl.a" | \
    while read lib; do \
        ln -vnf "$lib" quiche/deps/boringssl/src/lib/; \
    done

# Clone do curl
WORKDIR /opt
RUN git clone https://github.com/curl/curl

# Build do curl
WORKDIR /opt/curl
RUN git checkout $CURL_VERSION && \
    autoreconf -fi && \
    ./configure \
        LDFLAGS="-Wl,-rpath,/usr/local/lib" \
        --with-openssl=/opt/quiche/quiche/deps/boringssl/src \
        --with-quiche=/opt/quiche/target/release \
        --with-nghttp2 \
        --with-zlib \
        --with-libpsl \
        --with-zstd \
        --with-brotli \
        --disable-static \
        --disable-manual \
        --disable-docs && \
    make -j$(nproc) && \
    make DESTDIR="/staging/" install

# Limpa o que não é necessário em runtime
RUN rm -rf /staging/usr/local/include \
           /staging/usr/local/share \
           /staging/usr/local/lib/pkgconfig \
           /staging/usr/local/bin/curl-config

# Strip nos binários e libs para reduzir tamanho
RUN strip --strip-unneeded /staging/usr/local/bin/curl && \
    find /staging/usr/local/lib -name "*.so*" | xargs strip --strip-unneeded 2>/dev/null || true

# ── Imagem final ──────────────────────────────────────────────
FROM alpine:${ALPINE_VERSION}

RUN apk add --no-cache \
    ca-certificates \
    nghttp2-libs \
    zlib \
    libgcc \
    libpsl \
    zstd-libs \
    brotli-libs \
    bash \
    perl && \
    rm -rf /var/cache/apk/*

COPY --from=builder /staging/usr/local/ /usr/local/

RUN ldconfig /usr/local/lib || true

CMD ["curl"]
