# Build image
# Necessary dependencies to build Parrot
FROM rust:slim-bullseye as build

RUN apt-get update && apt-get install -y libopus-dev libssl-dev pkg-config

WORKDIR "/parrot"

# Cache cargo build dependencies by creating a dummy source
RUN mkdir src
RUN echo "fn main() {}" > src/main.rs
COPY Cargo.toml ./
COPY Cargo.lock ./
RUN cargo build --release --locked

COPY . .
RUN cargo build --release --locked

# Release image
# Necessary dependencies to run Parrot
FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y ffmpeg python3-pip
RUN pip install yt-dlp

WORKDIR "/parrot"

COPY --from=build /parrot/target/release/parrot /parrot

CMD ["./parrot"]
