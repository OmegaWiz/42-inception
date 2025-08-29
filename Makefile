NAME = make_inception
SRCS = ./srcs/docker-compose.yml

up:
	docker compose -f $(SRCS) -p $(NAME) up -d --build

up-w:
	docker compose -f $(SRCS) -p $(NAME) up -w --build

down:
	docker compose -f $(SRCS) -p $(NAME) down

prune:
	docker system prune -fa --volumes

.PHONY: up down
