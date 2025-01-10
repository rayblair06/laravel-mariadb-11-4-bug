# Use the official Alpine Linux image as the base
FROM alpine:latest

# Set environment variables for non-interactive installs
ENV DEBIAN_FRONTEND=noninteractive

# Set the working document
WORKDIR /var/www/html

# Install necessary packages including PHP, NGINX, and Supervisor
# - php83: PHP 8.3 and core extensions for modern web apps
# - nginx: Web server
# - supervisor: Process control system to manage multiple services (NGINX & PHP-FPM)
RUN apk add --no-cache \
    git \
    curl \
    nginx \
    mariadb-client \
    php83 \
    php83-ctype \
    php83-curl \
    php83-dom \
    php83-fileinfo \
    php83-fpm \
    php83-mbstring \
    php83-mysqli \
    php83-opcache \
    php83-openssl \
    php83-pdo \
    php83-pdo_mysql \
    php83-phar \
    php83-session \
    php83-sqlite3 \
    php83-tokenizer \
    php83-xml \
    supervisor

# Copy PHP confiuration files
# - www.conf - PHP FPM configuration
# - php.ini - PHP configuration
COPY Docker/php.conf /etc/php83/php-fpm.d/www.conf
COPY Docker/php.production.ini /etc/php83/php.ini

# Copy NGINX configuration files
# - nginx.conf: Main configuration for NGINX
# - default.conf: Default server configuration
COPY Docker/nginx.conf /etc/nginx/nginx.conf
COPY Docker/default.conf /etc/nginx/conf.d/default.conf

# Copy Supervisor configuration file
# - supervisord.conf: Configuration to manage NGINX and PHP-FPM processes
COPY Docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Ensure necessary directories and logs are accessible for the 'nobody' user
RUN mkdir -p /run /var/log/nginx /var/log/php83 && \
    chown -R nobody:nobody /var/www/html /run /var/lib/nginx /var/log/nginx

# Switch to a non-root user
USER nobody

# Copy application files and set permissions
COPY --chown=nobody . /var/www/html/

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Composer dependencies with optimized options for production
RUN composer install \
    --ignore-platform-reqs \
    --no-scripts \
    --no-progress \
    --no-ansi \
    --no-dev

# Expose the port on which NGINX will be accessible
EXPOSE 8080

# Start Supervisor, which will manage both NGINX and PHP-FPM
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to ensure the services are running
# - Uses curl to test if the server responds on port 8080
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080 || exit 1
