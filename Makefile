.PHONY: prechecks
prechecks: check-bundle-audit check-fasterer check-rubocop

.PHONY: check-rubocop
check-rubocop:
	bundle exec rubocop --parallel

.PHONY: check-fasterer
check-fasterer:
	bundle exec fasterer

PHONY: check-bundle-audit
check-bundle-audit:
	bundle audit check --update

.PHONY: run-worker
run-worker:
	cd ./worker && bin/server.sh

.PHONY: run-api
run-api:
	cd ./http_api && bin/server.sh

.PHONY: deps
deps:
	bundle install --gemfile ./worker/Gemfile
	bundle install --gemfile ./http_api/Gemfile

.PHONY: docker-setup
docker-setup:
	docker-compose build

.PHONY: docker-demo
docker-demo:
	docker-compose up

.PHONY: docker-services
docker-services:
	docker-compose -f docker-compose.services.yml up
