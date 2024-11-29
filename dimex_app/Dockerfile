# Start with a lightweight base image
FROM ubuntu:20.04

# Set non-interactive mode for installations
ENV DEBIAN_FRONTEND=noninteractive

# Install essential tools and dependencies for Flutter
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    wget \
    zip \
    lib32stdc++6 \
    libglu1-mesa \
    clang \
    cmake \
    ninja-build \
    libgtk-3-dev \
    libx11-dev \
    libxtst-dev \
    libxrandr-dev \
    libasound2-dev \
    xz-utils \
    openssl \
    ca-certificates \
    && apt-get clean

# Set Flutter version
ENV FLUTTER_VERSION=3.24.0

# Download and install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /opt/flutter \
    && cd /opt/flutter \
    && git checkout tags/${FLUTTER_VERSION} -b stable

# Add Flutter to PATH
ENV PATH="/opt/flutter/bin:$PATH"

# Enable Flutter analytics and check dependencies
RUN flutter config --no-analytics \
    && flutter doctor -v

# Set the working directory inside the container
WORKDIR /app

# Copy your Flutter project to the container
COPY . .

# Fetch dependencies for the Flutter project
RUN flutter pub get

# Generate launcher icons for the Flutter app
RUN flutter pub run flutter_launcher_icons:main

# Build the Flutter web application
RUN flutter build web --web-renderer canvaskit --release

# Use Nginx to serve the Flutter web app
FROM nginx:stable-alpine

# Copy the built web app to Nginx's serving directory
COPY --from=0 /app/build/web /usr/share/nginx/html

# Expose the default HTTP port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
