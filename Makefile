NAME=make_inception
SRCS=./srcs/docker-compose.yml
COMP=docker compose -f $(SRCS) -p $(NAME)

data:
	mkdir -p ${HOME}/data/mariadb_data
	mkdir -p ${HOME}/data/wordpress_data

secrets:
	mkdir -p secrets
	@set -e; for file in ./srcs/secrets-example/*; do \
		filename=$$(basename $$file); \
		if [ ! -f ./secrets/$$filename ]; then \
			cp $$file ./secrets/$$filename; \
			echo "Created ./secrets/$$filename"; \
		fi; \
	done

envar:
	@if [ ! -f ./srcs/.env ]; then \
		cp ./srcs/.env.example ./srcs/.env; \
		echo "Created ./srcs/.env"; \
	fi

utils: data secrets envar

up: utils
	$(COMP) up -d --build

watch: utils
	$(COMP) up -w --build

down:
	$(COMP) down

build: utils
	$(COMP) build --no-cache

re: clean build up

ps:
	$(COMP) ps

logs:
	$(COMP) logs -f

clean:
	$(COMP) down --volumes --remove-orphans

fclean: clean
	rm -rf ${HOME}/data/*

prune: fclean
	docker system prune -f -a --volumes

.PHONY: up down build re ps logs clean fclean prune utils data secrets envar watch
