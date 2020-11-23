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
