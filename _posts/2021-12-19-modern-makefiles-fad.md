---
title: Modern Makefiles are a fad
last_modified_at: 2023-09-08T09:53:19+02:00
tags: rant
---

# Modern Makefiles are a fad

## This is what Makefiles used to look like

```
CFLAGS = -Wall -W

all: mybinary README.html

mybinary: source1.o source2.o

README.html: README.md
	pandoc $^ -s -o $@

clean:
	rm -f *.o mybinary README.html

test:
	./tests.sh

.PHONY: clean test
```

Building target files out of source files, rebuilding them as source files changed.
Made to be run in parallel.

## This is how trendy devops teams use Makefiles in 2021

```
_DOCKER_FILTER = label=com.docker.compose.project=$(COMPOSE_PROJECT_NAME)

all: up

build: build-base-image
	docker-compose build

up:
	docker-compose up -d
	docker-compose run whatever /some/thing.sh

down:
	docker-compose down

build-base-image:
	docker build . --pull -f docker/base.Dockerfile -t base:latest

clean: down
	-docker volume ls --filter "$(_DOCKER_FILTER)" -q | xargs docker volume rm 

help:
	@echo build -- build images
	@echo up -- start containers
	@echo down -- stop containers
	@echo clean -- stop containers and remove volumes

.PHONY: all build up down build-base-image clean help
```

Not using files, not using timestamps. Mostly unparallelizable. Why using `make` then?
Not many devops people really used `make` before and so don't master it or know its quirks.

## This is what devops should really do

```
#!/bin/sh -e

_DOCKER_FILTER=label=com.docker.compose.project=${COMPOSE_PROJECT_NAME}

case "$1" in
	build)  # build images
		"$0" build-base-image
		docker-compose build ;;

	up|)  # start containers
		docker-compose up -d
		docker-compose run whatever /some/thing.sh ;;

	down)  # stop containers
		docker-compose down ;;

	build-base-image)
		docker build . --pull -f docker/base.Dockerfile -t base:latest ;;

	clean)  # stop containers and remove volumes
		"$0" down
		docker volume ls --filter "${_DOCKER_FILTER}" -q | xargs docker volume rm || true ;;

	*)
		grep ")  #" "$0"
		exit 64 ;;

esac
```

Plain old shell. No using an inappropriate tool.
Added bonus: it can handle arguments.
