# local-tap
This repo contains scripts to install Tanzu Application Platform (TAP) on 
Docker Desktop Kuberentes. To enable a single user tap deployment of tap 
for experimentaiton and educational purposes. 

## Prerequisets 

In order to complete the install you need to have the following ready.

1. DNS domain that points to 127.0.0.1 For example *.local.tanzu.ca should
   point to a local host. By having a wild card dns entry that points back 
   to localhost we can end up a domain name such as tap-gui.tap.local.tanzu.ca
   that works on the laptop running tap on docker-desktop. If you don't have 
   a DNS server you can just use local.tanzu.ca

2. Username and password for tanuz network that can be used to access the tanzu
   container registry where all the container images for TAP are stored.

3. Container registry where you can publish container images to, something like
   ghcr.io, googel artificat repository, or azure container service or Harbor.

4. GitHub OAuth application configured to allow login to the tap deployment you
   will need the client id and client secret 

5. a bunch of common cli tools installed, you probably have them if not you can 
  easily install them. 

## How networking works in this setup

TAP will be deployed with a contour ingress controller configured to use a 
K8s NodePort service as opposed to a LoadBalancer. Once TAP is up and running
the script in `07-proxy-traffic.sh` uses the `socat` utility to map prot 80
and 443 to the corresponding ports on the NodePort. this makes it possible to 
use the fully qualifed domain name during the install. 

# Deploy TAP on k8s

1. copy the `config/settings-template.sh` file to `config/settings.sh` 

2. edit the `config/settings.sh` file with your own values, there are lots of 
   comments in the `setting.sh` to guide along

3. run the scripts in this folder in sequence based on the script number and 
 you will end up with a working TAP. 

 

# Deploy Tailscale Kuberentes Operator

https://network.pivotal.io/products/tanzu-cluster-essentials/
https://network.pivotal.io/products/tanzu-application-platform