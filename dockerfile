# Use the base Python image
FROM python:3.13-rc-alpine

# Install necessary Python packages
RUN pip install html5lib html2text requests pyOpenSSL

# Create directories for the application and downloads
RUN mkdir -p /gogrepocdock/downloads

# Copy the Python script into the container
COPY gogrepoc.py /gogrepocdock

# Copy the entry-point script into the container
COPY entrypoint.sh /gogrepocdock

# Make the entry-point script executable
RUN chmod +x /gogrepocdock/entrypoint.sh

# Set the working directory
WORKDIR /gogrepocdock

# Set the entry-point script as the entry point for the Docker container
ENTRYPOINT ["./entrypoint.sh"]
