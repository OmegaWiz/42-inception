NAME = make_inception
SRCS = ./srcs/docker-compose.yml

up: data
	docker compose -f $(SRCS) -p $(NAME) up -d --build

up-w: data
	docker compose -f $(SRCS) -p $(NAME) up -w --build

down:
	docker compose -f $(SRCS) -p $(NAME) down

fclean: SHELL:=/bin/bash
fclean:
	bash -c "docker stop $(docker ps -qa)"
	bash -c "docker rm $(docker ps -qa)"
	bash -c "docker rmi -f $(docker images -qa)"
	bash -c "docker volume rm $(docker volume ls -q)"
	bash -c "docker network rm $(docker network ls -q)"
	rm -rf /home/kkaiyawo/data/*

prune:
	docker system prune -f -a --volumes
	sudo rm -rf /home/kkaiyawo/data/*

data:
	mkdir -p /home/kkaiyawo/data/mariadb_data
	mkdir -p /home/kkaiyawo/data/wordpress_data

.PHONY: up down
