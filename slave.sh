docker pull registry.aliyuncs.com/google_containers/kube-proxy:v1.13.0
docker pull registry.aliyuncs.com/google_containers/pause:3.1
docker pull calico/node:v3.1.4
docker pull calico/cni:v3.1.4
docker pull calico/typha:v3.1.4

docker tag registry.aliyuncs.com/google_containers/kube-proxy:v1.13.0 k8s.gcr.io/kubeproxy:v1.13.0
docker tag registry.aliyuncs.com/google_containers/pause:3.1 k8s.gcr.io/pause:3.1
docker tag calico/node:v3.1.4 quay.io/calico/node:v3.1.4
docker tag calico/cni:v3.1.4 quay.io/calico/cni:v3.1.4
docker tag calico/typha:v3.1.4 quay.io/calico/typha:v3.1.4

docker rmi registry.aliyuncs.com/google_containers/kube-proxy:v1.13.0
docker rmi registry.aliyuncs.com/google_containers/pause:3.1
docker rmi calico/node:v3.1.4
docker rmi calico/cni:v3.1.4
docker rmi calico/typha:v3.1.4

