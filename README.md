# kubeadm-k8s
kubeadm deploy k8s v1.13 rapidly, If you do not want to be another version, you need to configure the version you need in `env.sh`。
## 1. 准备条件
1.联网
2.虚拟机
| ip | 节点角色 | CPU | Memory | Hostname |
| ------ | ------ | ------ |------ | ------ |
| 192.168.211.12 | master and etcd | >=2c | >=2G | master |
| 192.168.211.13 | worker | >=2c | >=2G | node |


## 2. 准备操作
### 2.1 配置主机名
```bash
hostnamectl set-hostname master 
hostnamectl set-hostname node
```

### 2.2 配置主机互信

master执行
```bash
ssh-keygen     # 每台机器执行这个命令， 一路回车即可 
ssh-copy-id  node      # 到master上拷贝公钥到其他节点，这里需要输入 yes和密码
```

### 2.3 git拉取部署项目(全部执行)
```bash
yum -y install git
git clone https://github.com/Ghostwritten/kubeadm-k8s.git
cd kubeadm-k8s
```

### 2.4 配置环境变量
```bash
$ vim env.sh
#!/bin/bash

export master=192.168.211.12
export node=192.168.211.13
export version=v1.13.0
```

## 3. 初始化操作(全部执行)
```bash
bash init.sh
```

## 4. 检查(全部执行)
```bash
bash check.sh
```
最好重启reboot一遍。

## 5. 安装docker (全部执行)
```bash
bash docker.sh
```

## 6. 安装kubeadm、kubelet、kubectl 和下载镜像(全部执行)
```bash
bash k8s-start.sh
```
## 7. 部署master(master执行)
```bash
bash k8s-master.sh
```
生成的node节点加入集群命令保存至node节点中的`k8s-slave.sh`
例如：
```bash
$ cat k8s-slave.sh
....
addcluster() {
kubeadm join 192.168.211.12:6443 --token 7cu02j.niqbj187h4phhb8m --discovery-token-ca-cert-hash sha256:4fea6dcf0518246b4267b3cb31866ce9023f83ff11a052a834f38b73f885f5cf
}
```
## 8. 部署calico网络(master执行)_
```bash
bash calico-master.sh
```
检查状态
```bash
 kubectl get pods --all-namespaces
```

## 9. 部署node节点(node执行)
```bash
bash k8s-slave.sh
```
检查节点健康状态(master执行)
```bash
kubectl get pods
```

## 10. 部署dashboard

### 10.1 node下载`dashboard`镜像(node执行)
```bash
bash dashboard-slave.sh
```

### 10.2 部署`kubernetes-dashboard`(master执行)
```bash
bash dashboard.sh
```
**注意：如果配置443端口映射到外部主机30005上，需要修改`kubernetes-dashboard.yaml`**

修改`Service`类 添加 `nodePort`
格式如下：
```bash
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kube-system
spec:
  ports:
    - port: 443
      targetPort: 8443 
      nodePort: 30005  #手动添加
  type: NodePort       #手动添加
```
### 10.3 dashboard BUG处理
登录界面: http://<dashboard-ip>:8443
若配置端口映射，登录界面: http://<dashboard-ip>:30005
点击跳过
![avatar](https://img-blog.csdnimg.cn/20200419233923963.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3hpeGloYWhhbGVsZWhlaGU=,size_16,color_FFFFFF,t_70)
![avatar](https://img-blog.csdnimg.cn/20200419233941483.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3hpeGloYWhhbGVsZWhlaGU=,size_16,color_FFFFFF,t_70)

```bash
kubectl create -f kube-dashboard-access.yaml
```
刷新界面，问题解决。
![avatar](https://img-blog.csdnimg.cn/20200419234058939.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3hpeGloYWhhbGVsZWhlaGU=,size_16,color_FFFFFF,t_70)


## 11. 问题
### 11.1 The connection to the server localhost:8080 was refused - did you specify the right host or port?
node节点执行`kubectl get pods`报类似错误。
解决方法:(master执行)
```bash
scp /etc/kubernetes/admin.conf root@192.168.211.13:/root/.kube/config
```
