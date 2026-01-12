.PHONY: up down test-active-active test-network-partition deploy-jobs

up:
	docker-compose up -d --build
	@echo "Waiting for environment..."
	sleep 10
	@echo "Environment UP"

down:
	docker-compose down -v

deploy-jobs:
	# In a real localstack/nomad setup, we would submit jobs here.
	# For this POC, docker-compose starts the 'api-aws' and 'api-gcp' containers directly
	# which represent the output of the jobs.
	@echo "Jobs are running as docker containers."

test-active-active:
	bash tests/test_active_active.sh

test-network-partition:
	bash tests/test_network_partition.sh

test-failover:
	bash tests/test_failover.sh
