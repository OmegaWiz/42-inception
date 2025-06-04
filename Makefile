NAME = make_inception
SRCS = ./srcs/docker-compose.yml

up:
	docker compose -f $(SRCS) -p $(NAME) up -d

down:
	docker compose -f $(SRCS) -p $(NAME) down

.PHONY: up down
