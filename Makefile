# Define the name of the Minikube profile to use
MINIKUBE_PROFILE = minikube

# command line parameters
# CONFIG_FILE - yaml config used in the context of specific target

# Define the name of the Kubernetes namespace to use
NAMESPACE = dp_main

.PHONY: \
	full-start \
	full-stop \
	minikube-start \
	minikube-stop \
	minikube-logs

full-start: minikube-start
	helm install dpe-kafka ./charts/kafka
	helm install dpe-postgresql ./charts/postgresql
	helm install dpe-airflow ./charts/airflow
	helm install dpe-pythondev ./charts/pythondev

full-stop:
#	helm delete $(helm list --all --short)
	helm ls --all --short | xargs -L1 helm delete
	kubectl delete all --all
	minikube stop -p $(MINIKUBE_PROFILE)
	minikube delete

# Start the Minikube cluster and set up the Kubernetes context
minikube-start:
	minikube start -p $(MINIKUBE_PROFILE)
	minikube update-context -p $(MINIKUBE_PROFILE)
#	kubectl config set-context --current --namespace=$(NAMESPACE)

minikube-logs:
	minikube logs|less

# persistent disks commands
.PHONY: \
	create-persistent-volumes \
	delete-persistent-volumes \
	show-persistent-volumes

create-persistent-volumes:
ifndef CONFIG_FILE
	@echo "Error: CONFIG_FILE not defined."
else
	kubectl apply -f $(CONFIG_FILE)
endif

delete-persistent-volumes:
ifndef CONFIG_FILE
	@echo "Error: CONFIG_FILE not defined."
else
	@echo "Are you sure you want to delete the Persistent Volumes defined in $(CONFIG_FILE)? (y/n)"
	@read -p "" confirm; \
	if [ "$$confirm" = "y" ]; then \
		kubectl delete -f $(CONFIG_FILE); \
	fi
endif

show-persistent-volumes:
	kubectl get pv

.PHONY: helm-add-chart

helm-add-chart:
ifndef SW
	@echo "Error: SW not defined."
else
	helm pull bitnami/${SW}
	tar xvf ${SW}-*.tgz -C charts/
	helm dependency build "./charts/${SW}"
	rm ${SW}-*.tgz
endif

.PHONY: \
	postgresql-direct-pod-psql \
	postgresql-direct-pod-bash \
	postgresql-local-client \
	postgresql-client-pod-psql \
	python-direct-pod-bash \
	airflow-browser-connect

postgresql-direct-pod-psql:
	export POSTGRES_PASSWORD=$$(kubectl get secret --namespace default dpe-postgresql \
		-o jsonpath="{.data.postgres-password}" | base64 -d); \
	echo "postgres password: $$POSTGRES_PASSWORD"; \
	export POSTGRES_POD=$$(kubectl get pods -o name | grep 'postgres' | sed 's/^pod\///'); \
	kubectl exec $$POSTGRES_POD -it --namespace default \
	-- bash -c "/opt/bitnami/scripts/postgresql/entrypoint.sh /bin/bash & \
	PGPASSWORD=$$POSTGRES_PASSWORD psql -U postgres -d postgres -p 5432"

postgresql-direct-pod-bash:
	export POSTGRES_PASSWORD=$$(kubectl get secret --namespace default dpe-postgresql \
		-o jsonpath="{.data.postgres-password}" | base64 -d); \
	export POSTGRES_POD=$$(kubectl get pods -o name | grep 'postgres' | sed 's/^pod\///'); \
	echo "postgres password: $$POSTGRES_PASSWORD"; \
	kubectl exec $$POSTGRES_POD -it --namespace default \
	-- bash -c "PGPASSWORD=$$POSTGRES_PASSWORD /opt/bitnami/scripts/postgresql/entrypoint.sh /bin/bash"

postgresql-client-pod-psql:
	export POSTGRES_PASSWORD=$$(kubectl get secret --namespace default dpe-postgresql \
		-o jsonpath="{.data.postgres-password}" | base64 -d); \
	echo "postgres password: $$POSTGRES_PASSWORD"; \
	kubectl run dpe-postgresql-client --rm --tty -i --restart='Never' --namespace default \
	--image docker.io/bitnami/postgresql:latest --env="PGPASSWORD=$$POSTGRES_PASSWORD" \
	-- bash -c "/opt/bitnami/scripts/postgresql/entrypoint.sh /bin/bash & \
	psql --host dpe-postgresql -U postgres -d postgres -p 5432"

postgresql-local-client:
	export POSTGRES_PASSWORD=$$(kubectl get secret --namespace default dpe-postgresql \
		-o jsonpath="{.data.postgres-password}" | base64 -d)
	echo $$POSTGRES_PASSWORD
	kubectl port-forward --namespace default svc/dpe-postgresql 5432:5432 &
	PGPASSWORD="$$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432

python-direct-pod-bash:
	export POSTGRES_PASSWORD=$$(kubectl get secret --namespace default dpe-postgresql \
		-o jsonpath="{.data.postgres-password}" | base64 -d); \
	export PYTHON_POD=$$(kubectl get pods -o name | grep 'python' | sed 's/^pod\///'); \
	echo "postgres password: $$POSTGRES_PASSWORD"; \
	echo "python pod: $$PYTHON_POD"; \
	kubectl exec "$$PYTHON_POD" -it --namespace default \
	-- bash -c "PGPASSWORD=$$POSTGRES_PASSWORD"

airflow-browser-connect:
	kubectl port-forward --namespace default svc/dpe-airflow 8080:8080 &
	export AIRFLOW_PASSWORD=$$(kubectl get secret --namespace "default" dpe-airflow -o jsonpath="{.data.airflow-password}" | base64 -d)
	echo User:     user
	echo Password: $$AIRFLOW_PASSWORD
	echo "Airflow URL: http://127.0.0.1:8080"

.PHONY: \
	docker-full-stop \
	kafka-start-producer \
	kafka-start-consumer

docker-full-stop:
	sudo systemctl stop docker.service
	sudo systemctl stop docker.socket

kafka-start-producer:
	@if kubectl get pod dpe-kafka-client -o name 2>/dev/null | grep -q pod; then \
		echo "Pod dpe-kafka-client exists"; \
	else \
	    kubectl run dpe-kafka-client --restart='Never' \
		--image docker.io/bitnami/kafka:3.4.0-debian-11-r6 \
		--namespace default --command -- sleep infinity; \
	fi
	kubectl exec dpe-kafka-client --namespace default \
			-- bash -c "kafka-console-producer.sh \
			--broker-list dpe-kafka-0.dpe-kafka-headless.default.svc.cluster.local:9092 \
			--topic data_ingestion"

kafka-start-consumer:
	@if kubectl get pod dpe-kafka-client -o name 2>/dev/null | grep -q pod; then \
		echo "Pod dpe-kafka-client exists"; \
	else \
		kubectl run dpe-kafka-client --restart='Never' \
		--image docker.io/bitnami/kafka:3.4.0-debian-11-r6 \
		--namespace default --command -- sleep infinity; \
	fi
	kubectl exec dpe-kafka-client --namespace default \
			-- bash -c "kafka-console-consumer.sh \
            --bootstrap-server dpe-kafka.default.svc.cluster.local:9092 \
            --topic data_ingestion \
            --from-beginning"

.PHONY: docker-build

docker-build:
	$(info Running build of $(DIRECTORY))
	cd ./images/$(DIRECTORY); \
	docker build -t $(DIRECTORY) .
	docker tag $(DIRECTORY) josmac69berlin/$(DIRECTORY):latest
	docker push josmac69berlin/$(DIRECTORY):latest
