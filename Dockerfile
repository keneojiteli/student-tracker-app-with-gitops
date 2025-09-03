FROM python:3.10-slim-bullseye

# Update system packages to address vulnerabilities
RUN apt-get update && apt-get upgrade -y && apt-get clean

# Set workdir
WORKDIR /app

# Copy the project's requirements to leverage Docker's caching mechanism to the work directory
COPY requirements.txt .

# Install necessary dependencies without unnesessary caching
RUN pip install --no-cache-dir -r requirements.txt 

# Copy project
COPY . .

# Expose app port
EXPOSE 8000

# Start app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
