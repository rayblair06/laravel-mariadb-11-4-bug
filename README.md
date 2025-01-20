# Laravel MariaDB Issue with Alpine

This repository demonstrates an issue with the `mariadb-client` on Alpine Linux, where TLS/SSL is always enabled, leading to connection errors.

## Problem Description

When performing operations that rely on `mysql` (alias `mariadb-client`) (such as `schema:dump`), you may encounter the following error:

```
mysqldump: Deprecated program name. It will be removed in a future release, use '/usr/bin/mariadb-dump' instead
mysqldump: Got error: 2026: "TLS/SSL error: self-signed certificate in certificate chain" when trying to connect

  at vendor/symfony/process/Process.php:270
    266▕      */
    267▕     public function mustRun(?callable $callback = null, array $env = []): static
    268▕     {
    269▕         if (0 !== $this->run($callback, $env)) {
  ➜ 270▕             throw new ProcessFailedException($this);
    271▕         }
    272▕
    273▕         return $this;
    274▕     }
```

This error is caused by `mysqldump` enforcing TLS/SSL by default, even in non-SSL configurations.

---

## Setup and Reproduction

### 1. Build the Containers
Run the following command to build the Docker containers:

```bash
docker-compose -f docker-compose.yml build
```

### 2. Start the Containers
Start the application container:

```bash
docker-compose up -d --build app
```

### 3. Execute a MySQL Client Operation
Run an example operation, such as `schema:dump`, to reproduce the issue:

```bash
docker exec laravel-mariadb-11-4-bug-app-1 php artisan schema:dump
```
