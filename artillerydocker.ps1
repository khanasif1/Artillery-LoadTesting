docker images -a 
docker ps -a

docker rm artilleryloadtest -f
docker rmi artillery-aci:latest -f

docker build -t artillery-aci:latest .

docker run -d --name artilleryloadtest artillery-aci:latest


docker run  -it artilleryloadtest

docker logs --details  artilleryloadtest