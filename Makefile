SHELL = /bin/bash
.ONESHELL:

processor.up:
	@docker compose -f ../rinha-de-backend-2025/payment-processor/docker-compose.yml up -d

processor.down:
	@docker compose -f ../rinha-de-backend-2025/payment-processor/docker-compose.yml down --remove-orphans

friday-api.up:
	@docker compose up -d --build

friday-api.down:
	@docker compose down -v

rinha.test:
	@k6 run ../rinha-de-backend-2025/rinha-test/rinha.js
