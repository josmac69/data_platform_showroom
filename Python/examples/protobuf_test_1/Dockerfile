# Use a Python base image
FROM python:3.9-slim-buster

# Copy the protobuf script and requirements file into the container
COPY py_protobuf_1.py requirements.txt /app/

# Install required Python dependencies
RUN pip install -r /app/requirements.txt

# Set the working directory
WORKDIR /app

# Run the script on container start
CMD [ "python", "py_protobuf_1.py" ]
