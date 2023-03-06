# Define the name of the Minikube profile to use
MINIKUBE_PROFILE = minikube

# command line parameters
# CONFIG_FILE - yaml config used in the context of specific target

# Define the name of the Kubernetes namespace to use
NAMESPACE = mynamespace

.PHONY: start stop
# Start the Minikube cluster and set up the Kubernetes context
start:
	minikube start -p $(MINIKUBE_PROFILE)
	minikube update-context -p $(MINIKUBE_PROFILE)
#	kubectl config set-context --current --namespace=$(NAMESPACE)

# Stop the Minikube cluster
stop:
	kubectl delete all --all
	@if [[ $(helm list --all --short|wc -l) -gt 0 ]]; then \
		helm delete $(helm list --all --short); \
	else \
		echo "No Helm charts found."; \
	fi

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
