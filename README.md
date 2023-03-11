## Data platform pipeline example

* [Install docker engine](https://docs.docker.com/engine/install/ubuntu/)
    - in you encounter problems with docker you may need to reinstall it, in that case you need to [purge existing installation](https://askubuntu.com/questions/935569/how-to-completely-uninstall-docker)
    - short summary:
    ```
    sudo apt-get purge -y docker-engine docker docker.io docker-ce
    sudo apt-get autoremove -y --purge docker-engine docker docker.io docker-ce
    sudo umount /var/lib/docker/
    sudo rm -rf /var/lib/docker /etc/docker
    sudo rm /etc/apparmor.d/docker
    sudo groupdel docker
    sudo rm -rf /var/run/docker.sock
    sudo rm -rf /usr/bin/docker-compose
    sudo rm -rf ~/.docker
    ```
* [Set docker for usage without sudo](https://docs.docker.com/engine/install/linux-postinstall/)
    ```
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
    docker run hello-world
    docker info
    ```

* [Install minikube](https://minikube.sigs.k8s.io/docs/start/)
    - [how to remove minikube](https://stackoverflow.com/questions/66016567/how-to-uninstall-minikube-from-ubuntu-i-get-an-unable-to-load-cached-images-e)

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

* docker:
    - fully stop docker:
        - sudo systemctl stop docker
        - sudo systemctl stop docker.socket

* secrets:
    - echo -n 'MY_SECRET' | base64

* helm
    - create skeleton chart in charts directory: helm create mychart
    - testing dry run of new chart: helm install –dry-run  –debug c://sixchart/ –generate-name
    - list installed charts: helm list
