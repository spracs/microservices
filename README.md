# Docker
docker run hello-world
docker ps -a
docker images
docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}"
docker start <u_container_id>
docker attach <u_container_id> / ENTER
docker exec -it <u_container_id> bash
docker commit <u_container_id> yourname/ubuntu-tmp-file
docker inspect <u_container_id> # OR <u_image_id>
docker ps -q
docker kill $(docker ps -q)
docker system df
docker rm $(docker ps -a -q)
docker rmi $(docker images -q)

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
docker build -t reddit:latest .
docker images -a
docker run --name reddit -d --network=host reddit:latest

gcloud compute firewall-rules create reddit-app \
--allow tcp:9292 \
--target-tags=docker-machine \
--description="Allow PUMA connections" \
--direction=INGRESS

docker login
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
