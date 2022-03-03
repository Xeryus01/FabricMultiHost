docker-compose -f ./vm1/docker-compose.yaml up -d
sleep 2
docker-compose -f ./vm2/docker-compose.yaml up -d
sleep 2
docker-compose -f ./vm3/docker-compose.yaml up -d
sleep 2
docker-compose -f ./vm4/docker-compose.yaml up -d