NAME = make_inception
SRCS = ./srcs/docker-compose.yml

up: data
	docker compose -f $(SRCS) -p $(NAME) up -d --build

up-w: data
	docker compose -f $(SRCS) -p $(NAME) up -w --build

down:
	docker compose -f $(SRCS) -p $(NAME) down

prune:
	docker system prune -f -a --volumes
	sudo rm -rf /home/kkaiyawo/data/*

data:
	mkdir -p /home/kkaiyawo/data/mariadb_data
	mkdir -p /home/kkaiyawo/data/wordpress_data

.PHONY: up down
