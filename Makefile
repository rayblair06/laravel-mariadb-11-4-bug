# QoL commands

build:
	@docker-compose -f docker-compose.yml build

start:
	@docker-compose up -d --build app

migrate:
	@docker exec laravel-mariadb-11-4-bug-app migrate

seed:
	@docker exec laravel-mariadb-11-4-bug-app migrate:fresh --seed

composer-install:
	@docker-compose run --rm composer install

composer-update:
	@docker-compose run --rm composer update
