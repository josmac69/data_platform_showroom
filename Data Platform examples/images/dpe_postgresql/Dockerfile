FROM postgres:bullseye

# Install git command
RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

CMD ["postgres"]
