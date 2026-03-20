FROM alpine:3.23 AS builder

WORKDIR /opt

ARG CURL_VERSION=curl-8_19_0
ARG QUICHE_VERSION=0.24.2

RUN apk add --no-cache \
    build-base git autoconf automake libtool cmake go \
    curl nghttp2-dev zlib-dev perl linux-headers \
    libpsl-dev \
    zstd-dev \
    brotli-dev

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y -q

RUN git clone --recursive https://github.com/cloudflare/quiche

RUN export PATH="$HOME/.cargo/bin:$PATH" && \
    cd quiche && \
    git checkout $QUICHE_VERSION && \
    cargo build --package quiche --release --features ffi,pkg-config-meta,qlog && \
    mkdir quiche/deps/boringssl/src/lib && \
    ln -vnf $(find target/release -name libcrypto.a -o -name libssl.a) \
        quiche/deps/boringssl/src/lib/

RUN git clone https://github.com/curl/curl

RUN cd curl && \
    git checkout $CURL_VERSION && \
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
        --without-libpsl \
        --disable-static \
        --disable-manual \
        --disable-docs && \
    make -j$(nproc) && \
    make DESTDIR="/staging/" install

# ── Limpa o que não é necessário em runtime ──────────────────
RUN rm -rf /staging/usr/local/include \
           /staging/usr/local/share \
           /staging/usr/local/lib/pkgconfig \
           /staging/usr/local/bin/curl-config

# Strip nos binários e libs para reduzir tamanho
RUN strip --strip-unneeded /staging/usr/local/bin/curl
RUN find /staging/usr/local/lib -name "*.so*" | xargs strip --strip-unneeded 2>/dev/null || true

# ── Copia SOMENTE a libquiche.so (não o target/release inteiro!) ──
# ── Copia SOMENTE a libquiche (não o target/release inteiro!) ──
RUN mkdir -p /quiche-libs && \
    find /opt/quiche/target/release -maxdepth 1 \( -name "libquiche.so*" -o -name "libquiche.dylib" \) \
        -exec cp {} /quiche-libs/ \; && \
    ls -lah /quiche-libs/ && \
    find /quiche-libs -name "*.so*" | xargs strip --strip-unneeded 2>/dev/null || true

# ── Imagem final ──────────────────────────────────────────────
FROM alpine:3.23

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
COPY --from=builder /quiche-libs/ /usr/local/lib/

RUN ldconfig /usr/local/lib || true

RUN wget -qO /usr/local/bin/httpstat \
https://raw.githubusercontent.com/babarot/httpstat/master/httpstat && \
chmod +x /usr/local/bin/httpstat

CMD ["curl"]