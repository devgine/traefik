##----------------------------------------------------------------------------------------------------------------------
##------------------------------------------ Stack Makefile -------------------------------------------
##----------------------------------------------------------------------------------------------------------------------
DC=docker compose

.DEFAULT_GOAL := help
.PHONY: help
help : Makefile # Print commands help.
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

export
HOST_UID=$(shell id -u)
HOST_GID=$(shell id -g)
TRAEFIK_NETWORK=traefik-network
TRAEFIK_NETWORK_EXISTS=$(shell docker network list | grep ${TRAEFIK_NETWORK} | wc -l)

##
## Docker
##----------------------------------------------------------------------------------------------------------------------
.PHONY: config down down-v init logs ps restart start stop up

config: ## Display the manifest
	$(DC) config

down: ## Remove containers and networks (possible to down specific containers with "make down c1 c2")
	$(DC) down $(filter-out $@,$(MAKECMDGOALS))

down-v: ## Remove containers, networks and volumes (possible to down specific containers with "make down-v c1 c2")
	$(DC) down -v $(filter-out $@,$(MAKECMDGOALS))

init: ## Init docker networks
	@echo "Checking for network"
	docker network create ${TRAEFIK_NETWORK} || true

logs: ## Display container logs (exp: make logs angular)
	$(DC) logs -f -n 20 $(filter-out $@,$(MAKECMDGOALS))

ps: ## List containers
	$(DC) ps -a

restart: ## Restart containers (possible to restart specific containers with "make restart c1 c2")
	$(DC) restart $(filter-out $@,$(MAKECMDGOALS))

start: ## Start containers (possible to start specific containers with "make start c1 c2")
	$(DC) start $(filter-out $@,$(MAKECMDGOALS))

stop: ## Stop containers (possible to stop specific containers with "make stop c1 c2")
	$(DC) stop $(filter-out $@,$(MAKECMDGOALS))

up: init ## Create and start containers
	@echo "Starting up containers"
	$(DC) up -d --build --remove-orphans --force-recreate

##
## Shell
##----------------------------------------------------------------------------------------------------------------------
.PHONY: traefik-shell

traefik-shell: ## Connect to traefik container
	$(DC) exec traefik sh
