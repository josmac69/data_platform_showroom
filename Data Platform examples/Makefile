# Define the name of the Minikube profile to use
MINIKUBE_PROFILE = minikube

# command line parameters
# CONFIG_FILE - yaml config used in the context of specific target

# Define the name of the Kubernetes namespace to use
NAMESPACE = dp_main

.PHONY: full-start full-stop minikube-start minikube-stop minikube-logs

full-start: minikube-start
	helm install dpe-kafka ./charts/kafka
	helm install dpe-postgresql ./charts/postgresql -f ./decrypted/values.yaml -f ./decrypted/secrets.yaml

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
.PHONY: create-persistent-volumes delete-persistent-volumes show-persistent-volumes

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

.PHONY: postgresql-pod-connect postgresql-local-connect

postgresql-pod-connect:
	export POSTGRES_PASSWORD=$$(kubectl get secret --namespace default dpe-postgresql \
		-o jsonpath="{.data.postgres-password}" | base64 -d); \
	echo "postgres password: $$POSTGRES_PASSWORD"; \
	kubectl run dpe-postgresql-client --rm --tty -i --restart='Never' --namespace default \
	--image docker.io/bitnami/postgresql:15.2.0-debian-11-r5 --env="PGPASSWORD=$$POSTGRES_PASSWORD" \
	--command -- psql --host dpe-postgresql -U postgres -d postgres -p 5432

postgresql-local-connect:
	export POSTGRES_PASSWORD=$$(kubectl get secret --namespace default dpe-postgresql \
		-o jsonpath="{.data.postgres-password}" | base64 -d)
	echo $$POSTGRES_PASSWORD
	kubectl port-forward --namespace default svc/dpe-postgresql 5432:5432 &
	PGPASSWORD="$$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432

.PHONY: docker-full-stop kafka-start-producer kafka-start-consumer

docker-full-stop:
	sudo systemctl stop docker.service
	sudo systemctl stop docker.socket

kafka-start-producer:
	@if kubectl get pod dpe-kafka-client -o name 2>/dev/null | grep -q pod; then \
		echo "Pod dpe-kafka-client exists"; \
	else \
	    kubectl run dpe-kafka-client --restart='Never' --image docker.io/bitnami/kafka:3.4.0-debian-11-r6 --namespace default --command -- sleep infinity; \
	fi
	kubectl exec dpe-kafka-client --namespace default \
			-- bash -c "kafka-console-producer.sh \
			--broker-list dpe-kafka-0.dpe-kafka-headless.default.svc.cluster.local:9092 \
			--topic data_ingestion"

kafka-start-consumer:
	@if kubectl get pod dpe-kafka-client -o name 2>/dev/null | grep -q pod; then \
		echo "Pod dpe-kafka-client exists"; \
	else \
	    kubectl run dpe-kafka-client --restart='Never' --image docker.io/bitnami/kafka:3.4.0-debian-11-r6 --namespace default --command -- sleep infinity; \
	fi
	kubectl exec dpe-kafka-client --namespace default \
			-- bash -c "kafka-console-consumer.sh \
            --bootstrap-server dpe-kafka.default.svc.cluster.local:9092 \
            --topic data_ingestion \
            --from-beginning"
