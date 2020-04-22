#!/bin/bash


newtag=k8s.gcr.io
for i in $(docker images | grep google_containers | grep "v1.13.0" | grep -v TAG |awk '{print $1 ":" $2}')
do
   image=$(echo $i | awk -F '/' '{print $3}')
   docker tag $i $newtag/$image
   docker rmi $i
done
   
for i in $(docker images |grep "google_containers"| grep -v TAG |awk '{print $1 ":" $2}')
do
   image=$(echo $i | awk -F '/' '{print $3}')
   docker tag $i $newtag/$image
   docker rmi $i
done
