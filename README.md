# kubectl-kubescan
Kubescan is a  multi-cloud solution,scanning for errored pods and containers, potentially with visibility for security issues,
simplifying kubernetes troubleshooting
Tested on Azure, Google Cloud Platform (GCP), IBM Cloud.

Pre-requisites
kubectl installed.

Install:

git clone https://github.com/Kubenew/kubectl-kubescan.git

cd kubectl-kubescan

$ chmod 755 kubescan.sh

 $ ./kubescan.sh
 
 
 ![kubescan](https://user-images.githubusercontent.com/90440279/148094639-4f05f050-5ed2-40dc-b3fc-91e6a4957e9b.png)

Your clusters kubeconfig either in its default location ($HOME/.kube/config) or exported (KUBECONFIG=/path/to/kubeconfig)
Usage
$ bash kubescan $ ./kubescan.sh
