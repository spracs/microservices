# Docker
docker run hello-world  # Скачивание образа их хаба, создание контейнера из образа и запуск контейнера
docker ps -a            # Список всех контейнеров
docker images           # Список образов
docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}"
docker start <u_container_id>   # Запуск созданного контейнера
docker attach <u_container_id> / ENTER      # подсоединяет терминал к созданному контейнеру
docker exec -it <u_container_id> bash       # Запускает новый процесс внутри контейнера (напр bash)
docker commit <u_container_id> yourname/ubuntu-tmp-file     # Создает image из контейнера
docker inspect <u_container_id> # OR <u_image_id>
docker ps -q
docker kill $(docker ps -q)     # Остановить все запущенные контейнеры
docker system df                # Отображает сколько дискового пространства занято образами, контейнерами и volume’ами
docker rm $(docker ps -a -q)    # Удалить все контейнеры
docker rmi $(docker images -q)  # Удалить все образы

# Docker Machine
gcloud init
gcloud auth application-default login
export GOOGLE_PROJECT=docker-*******

docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-zone europe-west1-b \
docker-host

docker-machine ls
eval $(docker-machine env docker-host)
eval $(docker-machine env -u)
docker build -t reddit:latest .     # Создание образа из Dockerfile
docker images -a
docker run --name reddit -d --network=host reddit:latest

gcloud compute firewall-rules create reddit-app \
--allow tcp:9292 \
--target-tags=docker-machine \
--description="Allow PUMA connections" \
--direction=INGRESS

docker login        # Авторизация в Docker HUB
docker tag reddit:latest <your-login>/test-reddit:1.0
docker push <your-login>/test-reddit:1.0
docker run --name reddit -d -p 9292:9292 <your-login>/test-reddit:1.0
docker logs reddit -f           # изучить логи контейнера
docker exec -it reddit bash     # зайти в выполняемый контейнер
    $ killall5 1                # вызвать остановку контейнера
docker start reddit             # запустить его повторно
docker stop reddit && docker rm reddit                                  # остановить и удалить
docker run --name reddit --rm -it <your-login>/test-reddit:1.0 bash     # запустить контейнер без запуска приложения
docker exec -it reddit bash 
docker diff reddit

# linter для Dockerfile
docker run --rm -i hadolint/hadolint < Dockerfile

# Build from Dockerfile
docker build -t <your-dockerhub-login>/post:1.0 ./post-py
...
docker network create reddit    # Создание сети для приложения
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post <your-dockerhub-login>/post:1.0
docker run -d --network=reddit --network-alias=comment <your-dockerhub-login>/comment:1.0
docker run -d --network=reddit -p 9292:9292 <your-dockerhub-login>/ui:1.0

docker volume create reddit_db  # Создание хранилища Docker Volume
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest

# Networks
docker network create back_net --subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24
docker network connect front_net comment

# Docker-compose
docker-compose up -d    # создание и запуск контейнеров из docker-compose.yml
docker-compose down     # остановка и удаление контейнеров
docker-compose -p projectName up -d
docker-compose ps
docker-compose kill
docker-compose -p test -f docker-compose.yml up -d

# local gitlab
git remote add gitlab http://34.78.106.137/homework/example.git
git push gitlab gitlab-ci-1
git tag 2.4.10
git push gitlab gitlab-ci-1 --tags

docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest
docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false

# monitoring
for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done

docker-compose -f docker-compose-monitoring.yml up -d
gcloud compute firewall-rules create cadvisor-default --allow tcp:8080

# logging
docker-machine create --driver google --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts --google-machine-type n1-standard-1 --google-zone europe-west1-b --google-open-port 5601/tcp --google-open-port 9292/tcp --google-open-port 9411/tcp logging
eval $(docker-machine env logging)
docker-machine ip logging

# kubernates
# https://github.com/kelseyhightower/kubernetes-the-hard-way


kubectl create secret generic kubernetes-the-hard-way \                         # verify the ability to encrypt secret data at rest.
  --from-literal="mykey=mydata"
gcloud compute ssh controller-0 \
  --command "sudo ETCDCTL_API=3 etcdctl get \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem\
  /registry/secrets/default/kubernetes-the-hard-way | hexdump -C"

kubectl create deployment nginx --image=nginx                                           # Deployments
kubectl get pods -l app=nginx

POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}")     # Port Forwarding
kubectl port-forward $POD_NAME 8080:80

kubectl logs $POD_NAME                                                                  # Logs
kubectl exec -ti $POD_NAME -- nginx -v                                                   # Exec

kubectl expose deployment nginx --port 80 --type NodePort                               # Services
NODE_PORT=$(kubectl get svc nginx \
  --output=jsonpath='{range .spec.ports[0]}{.nodePort}')
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-nginx-service \
  --allow=tcp:${NODE_PORT} \
  --network kubernetes-the-hard-way
EXTERNAL_IP=$(gcloud compute instances describe worker-0 \
  --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')
curl -I http://${EXTERNAL_IP}:${NODE_PORT}

kubectl config current-context      # Текущий контекст
kubectl config get-contexts         # Список всех контекстов
kubectl apply -f ui-deployment.yml  # развертывание из одного YML
kubectl get deployment
kubectl apply -f ./kubernetes/reddit  # Развертывание из папки с YML

kubectl get pods --selector component=ui
kubectl port-forward <pod-name> 8080:9292 # Проброс локального порта

kubectl describe pod <pod-name>           # Информация о состоянии

kubectl delete -f name.yml # OR kubectl delete service <service-name>

# Minikube
minikube start
minikube service list
minikube addons list
minikube service list -n dev

# GKE
kubectl get nodes -o wide
kubectl describe service ui -n dev | grep NodePort

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
kubectl proxy
kubectl get secret $(kubectl get sa kubernetes-dashboard -o jsonpath='{.secrets[0].name}' -n kubernetes-dashboard) -n kubernetes-dashboard -o jsonpath='{.data.token}' | base64 --decode

kubectl scale deployment --replicas 0 -n kube-system kube-dnsautoscaler
kubectl scale deployment --replicas 0 -n kube-system kube-dns
kubectl scale deployment --replicas 1 -n kube-system kube-dnsautoscaler

kubectl get ingress -n dev

# TLS
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=34.117.104.89"
kubectl create secret tls ui-ingress --key tls.key --cert tls.crt -n dev
kubectl describe secret ui-ingress -n dev

# HELM
helm install some-name path-to-Charm/
helm ls
helm dep update

helm repo add stable https://charts.helm.sh/stable    # adding repository
helm search repo mongodb

helm upgrade some-name path-to-Charm/

# HELM GitLab
helm repo add gitlab https://charts.gitlab.io
helm repo add bitnami https://charts.bitnami.com/bitnami
helm fetch gitlab/gitlab-omnibus --version 0.1.37 --untar
helm ls -n review

# GitLab last version
helm repo add gitlab https://charts.gitlab.io/
helm upgrade --install gitlab gitlab/gitlab   --set global.hosts.domain=34-76-194-172.sslip.io   --set global.hosts.externalIP=34.76.194.172   --set certmanager-issuer.email=me@example.com --set gitlab-runner.runners.privileged=true --set global.kas.enabled=true --set global.hosts.https=false --set global.ingress.tls.enabled=false --version 4.9.3
Пароль root:
kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo

helm upgrade --install gitlab gitlab/gitlab --version 4.9.3 -f values.yaml


# Kubernetes monitoring
helm repo add nginx-stable https://helm.nginx.com/stable
helm nginx install stable/nginx-ingress

helm upgrade --install grafana stable/grafana --set "adminPassword=admin" \
--set "service.type=NodePort" \
--set "ingress.enabled=true" \
--set "ingress.hosts={reddit-grafana}"

# Kubernetes logging
helm upgrade --install kibana stable/kibana \
--set "ingress.enabled=true" \
--set "ingress.hosts={reddit-kibana}" \
--set "env.ELASTICSEARCH_URL=http://elasticsearch-logging:9200" \
--version 0.1.1

