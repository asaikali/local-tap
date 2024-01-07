# local-tap
This repo contains scripts to install Tanzu Application Platform (TAP) on 
Docker Desktop Kuberentes. To enable a single user TAP deployment of TAP
for experimentaiton and educational purposes. 

## Prerequisites

In order to complete the install, you need to have the following ready:

1. DNS domain that points to 127.0.0.1 For example *.local.tanzu.ca should
   point to a local host. By having a wild card dns entry that points back 
   to localhost we can end up a domain name such as tap-gui.tap.local.tanzu.ca
   that works on the laptop running tap on docker-desktop. If you don't have 
   a DNS server you can just use local.tanzu.ca

2. Username and password for Tanzu network that can be used to access the Tanzu
   container registry where all the container images for TAP are stored.

3. Container registry where you can publish container images to, something like
   [GitHub Packages](ghcr.io), [Google Artifact Registry](https://cloud.google.com/artifact-registry),
   [Azure Container Registry](https://azure.microsoft.com/en-us/products/container-registry)
   or [Harbor](https://goharbor.io/).

5. GitHub OAuth application configured to allow login to the tap deployment you
   will need the client id and client secret 

6. A bunch of common CLI tools installed. You probably have them. If not, you can 
   easily install them. 

## How networking works in this setup

TAP will be deployed with a Contour ingress controller configured to use a 
K8s NodePort service as opposed to a LoadBalancer. Once TAP is up and running
the script in `07-proxy-traffic.sh` uses the `socat` utility to map port 80
and 443 to the corresponding ports on the NodePort. This makes it possible to 
use the fully qualifed domain name during the install.

# Deploy TAP on k8s

1. Copy the `config/settings-template.sh` file to `config/settings.sh` 

2. Edit the `config/settings.sh` file with your own values. There are lots of 
   comments in the `setting.sh` to guide along.

3. Run the scripts in this folder in sequence based on the script number and 
   you will end up with a working TAP. 
