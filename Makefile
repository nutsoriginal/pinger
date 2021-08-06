.PHONY: prechecks
prechecks: check-bundle-audit check-brakeman check-fasterer check-rubocop

.PHONY: check-rubocop
check-rubocop:
	-cd ./worker && bundle exec rubocop --parallel
	cd ./http_api && bundle exec rubocop --parallel

.PHONY: check-brakeman
check-brakeman:
	bundle exec brakeman -A --no-progress --no-pager

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
