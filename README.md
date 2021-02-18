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
