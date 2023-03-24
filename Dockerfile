FROM --platform=$BUILDPLATFORM rust:alpine AS build
COPY . /app
WORKDIR /app
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
ARG TARGETARCH
RUN case ${TARGETARCH} in \
  arm64) echo aarch64-unknown-linux-musl > /.target ;; \ 
  amd64) echo x86_64-unknown-linux-musl > /.target ;; \
  *) exit 1 ;; \
esac
RUN apk add --update musl-dev \
    && rustup target add $(cat /.target) \
    && cargo build -p typst-cli --release --target $(cat /.target) \
    && mv target/$(cat /.target)/release/typst target/release

FROM --platform=$TARGETPLATFORM alpine:latest  
WORKDIR /root/
COPY --from=build  /app/target/release/typst /bin
