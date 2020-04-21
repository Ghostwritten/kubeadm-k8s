#!/bin/bash

newtag=k8s.gcr.io
for i in $(docker images |grep "v1.18.1"| grep -v TAG |awk '{print $1 ":" $2}')
do
   image=$(echo $i | awk -F '/' '{print $3}')
   docker tag $i $newtag/$image
   docker rmi $i
done
