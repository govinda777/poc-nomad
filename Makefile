.PHONY: up down vpn-up vpn-down test-active-active test-network-partition build-app setup-db

up: build-app
	docker-compose up -d
	@echo "Waiting for services to stabilize..."
	sleep 10
	make setup-db
	make vpn-up
	make deploy-jobs
	@echo "Environment Ready."

down:
	docker-compose down -v
	sudo rm -rf terraform/localstack-aws/.ready terraform/localstack-gcp/.ready

build-app:
	sudo docker build -t poc-app app/

setup-db:
	@echo "Initializing Database..."
	# We need to wait for Postgres to be up.
	sleep 10
	# Create table in Primary
	# Piped input to avoid mounting issues
	cat database/init.sql | docker exec -i postgres-aws-primary psql -U poc -d pocdb

	@echo "Setting up Replication..."
	./database/scripts/setup_replication.sh

deploy-jobs:
	@echo "Deploying Nomad Jobs (Simulation)..."
	# In this local POC, the 'api' containers are running via docker-compose for easy networking/port access.
	# However, we submit the jobs to Nomad to demonstrate the orchestration aspect.
	# The Nomad clients are running in docker containers (nomad-server-aws/gcp acts as client too).
	# They need access to the docker socket (mounted in compose).

	# We export the Nomad address to point to AWS DC first
	export NOMAD_ADDR=http://localhost:4646
	nomad job run nomad/api.nomad.hcl || echo "Nomad job submission failed (is nomad running?)"
	nomad job run nomad/consumer.nomad.hcl || echo "Nomad job submission failed"

vpn-up:
	./scripts/network_sim/vpn_up.sh

vpn-down:
	./scripts/network_sim/vpn_down.sh

test-active-active:
	./tests/test_active_active.sh

test-network-partition:
	./tests/test_network_partition.sh
