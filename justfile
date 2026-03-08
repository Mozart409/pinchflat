# https://just.systems

default: dev

dev: clear
    docker compose build && docker compose up -d && docker attach pinchflat-phx-1

clear:
    clear

down: clear
    docker compose down

test: clear
    docker compose run --rm phx mix test

