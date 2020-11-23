# Docker
docker run hello-world
docker ps -a
sudo docker images
docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}"
docker start <u_container_id>
docker attach <u_container_id> / ENTER
docker exec -it <u_container_id> bash
docker commit <u_container_id> yourname/ubuntu-tmp-file
