## Data platform pipeline example

* [Install minikube](https://minikube.sigs.k8s.io/docs/start/)
* [Install Helm](https://helm.sh/docs/intro/install/)
* [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
* For interactions with minikube cluster download [Octant](https://octant.dev/)
    - Note: I used to use [Lens Desktop](https://k8slens.dev) and I loved it but it now only in payed version 
* 

* [Install Prometheus-operator](https://bitnami.com/stack/prometheus-operator/helm) for monitoring
    - to access prometheus from your browser run port forwarding
        - kubectl port-forward --namespace default svc/my-release-kube-prometheus-prometheus 9090:9090
    - open in browser [http://127.0.0.1:9090/](http://127.0.0.1:9090/)
* [Install Grafana](https://bitnami.com/stack/grafana/helm)




#### Useful commands

* minikube:
    - minikube status
    - minikube profile
    - minikube profile list
