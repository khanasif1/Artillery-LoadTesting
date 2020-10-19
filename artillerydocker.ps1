docker images -a 
docker ps -a


#***********************
#****Build Image********
#***********************

docker build -t artillery-aci:latest .


#***********************
#******RUN Image********
#***********************

docker run -d --name artilleryloadtest artillery-aci:latest


#***********************
#****Get Container Log**
#***********************

docker logs --details  artilleryloadtest


#***********************
#****Cleanup container**
#***********************


docker rm artilleryloadtest -f
docker rmi artillery-aci:latest -f