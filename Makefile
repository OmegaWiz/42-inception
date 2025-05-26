NAME = make_inception
SRCS = ./conf/docker-compose.yml

up:
	docker compose -f $(SRCS) -p $(NAME) up -d

down:
	docker compose -f $(SRCS) -p $(NAME) down

.PHONY: up
