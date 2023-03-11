FROM python:3.6.15-bullseye

# Install git command
RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/

# Install required Python dependencies
RUN pip install --verbose -r /app/requirements.txt

CMD ["bash"]
