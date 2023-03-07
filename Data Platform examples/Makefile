# Define the name of the Minikube profile to use
MINIKUBE_PROFILE = minikube

# command line parameters
# CONFIG_FILE - yaml config used in the context of specific target

# Define the name of the Kubernetes namespace to use
NAMESPACE = dp_main

.PHONY: minikube-start minikube-stop
# Start the Minikube cluster and set up the Kubernetes context
minikube-start:
	minikube start -p $(MINIKUBE_PROFILE)
	minikube update-context -p $(MINIKUBE_PROFILE)
#	kubectl config set-context --current --namespace=$(NAMESPACE)

# Stop the Minikube cluster
minikube-stop:
	helm delete $(helm list --all --short);
	kubectl delete all --all

	minikube stop -p $(MINIKUBE_PROFILE)

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

helm-install-all: minikube-start
	helm install dpe-kafka ./charts/kafka
	helm install dpe-postgresql ./charts/postgresql

.PHONY: postgresql-connect-to-pod postgresql-local-connect

postgresql-connect-to-pod:
	export POSTGRES_PASSWORD=$(kubectl get secret --namespace default dpe-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
	kubectl run dpe-postgresql-client --rm --tty -i --restart='Never' --namespace default \
	--image docker.io/bitnami/postgresql:15.2.0-debian-11-r5 --env="PGPASSWORD=$POSTGRES_PASSWORD" \
    --command -- psql --host dpe-postgresql -U postgres -d postgres -p 5432

postgresql-local-connect:
	export POSTGRES_PASSWORD=$(kubectl get secret --namespace default dpe-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
	kubectl port-forward --namespace default svc/dpe-postgresql 5432:5432 &
	PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432
