build:
	docker compose build

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose down
	docker compose up -d

logs:
	docker compose logs -f

ps:
	docker compose ps

# コンテナ内に入れ、python, pip list, conda listなどの確認ができる
shell:
	docker exec -it my-env bash

jupyter:
	open http://localhost:8888