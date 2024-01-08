# local-tap
This repo contains scripts to install Tanzu Application Platform (TAP) on 
Docker Desktop Kuberentes. To enable a single user TAP deployment of TAP
for experimentaiton and educational purposes. 

## Prerequisites

In order to complete the install, you need to have the following ready:

0. Docker Desktop with Kuberentes turned on. You can probably use minikube to 
   if you wish but I have found Docker Desktop Kuberentes to work reasonably 
   well with the least hassle. Contribution documenting how to use the scripts
   in this repo with minikube are welcome. 

1. Username and password for Tanzu network that can be used to access the Tanzu
   container registry where all the container images for TAP are stored. You need
   to accept the EULA see [docs](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/install-tanzu-cli.html)
   otherwise you container image pulls will fail. 

2. Container registry where you can publish container images to, something like
   [GitHub Packages](ghcr.io), [Google Artifact Registry](https://cloud.google.com/artifact-registry),
   [Azure Container Registry](https://azure.microsoft.com/en-us/products/container-registry)
   or [Harbor](https://goharbor.io/).

3. GitHub OAuth application configured to allow login to the tap deployment you
   will need the client id and client secret 

4. A bunch of common CLI tools installed. You probably have them. If not, you can 
   easily install them. 

5. (Optional) DNS domain that points to 127.0.0.1. You can use *.local.tanzu.ca 
   if you don't have your own domain. By having a wild card dns entry that points back 
   to localhost we can end up a domain name such as tap-gui.tap.local.tanzu.ca
   that works on the laptop running tap on docker-desktop. If you don't have 
   a DNS server you can just use local.tanzu.ca 

## How networking works when deploying on Docker Desktop Kuberenetes

By default TAP deploys the contour ingress controller using a Kuberentes LoadBalancer service.
To avoid problems with LoadBalancer service on dev machine running Docker desktop or minikube 
we change the configuration of tap to use a NodePort Service instead. 

Once TAP is up and running it will be exposed on two random port numbers selecetd by
Kuberentes. You can run the script `05-proxy-traffic.sh` which map port 80 and 443
on your machine to the NodePort values selected by Kuberentes. The script uses
the `socat` utlity. 

If you the default `tap.local.tanzu.ca` base domain then you can find TAP GUI
at [https://tap-gui.tap.local.tanzu.ca](https://tap-gui.tap.local.tanzu.ca) 


## Deploy TAP on Docker Desktop Kuberenets

The install process is done via serries of scripts located at the root of
the repo. The scripts are idempotent you can run them mulitple times and they
shoud pickup where they left of. 

1. run the script `00-validate-clis-are-installed.sh` it will check that all 
   the required clis are installed on your machine. 

2. Copy the `config/settings-template.sh` file to `config/settings.sh` 

3. Edit the `config/settings.sh` file with your own values. There are lots of 
   comments in the `setting.sh` to guide along.

4. Run the script `01-validate-registry-access-and-credentials.sh` this will check
   that the tap registry and the workload registry can be accessed form your machine

5. Run the script `02-install-cluster-essentials.sh` to install kapp-controller 
   and secret gen controller on your cluster.

6. Run the script `03-configure-tap-install-namespace.sh` to prepare the tap-install namespace.

7. Run the script `04-install-tap.sh` to install all the tap packages. This will take 
   5 to 15 minutes depending on your internet connection speed and the amount of resources
   avilable to your docker desktop k8s. You can monitory progress by running the script 
   `20-debug-watch-package-installs.sh`

8. When all the TAP packages are reconcilend run the script `05-proxy-traffic.sh` to
   map port 80 and 443 to the contour ingress node ports.

9. Optionally install spring cloud gateway using script `06-install-spring-cloud-gateway.sh` and
   `07-install-application-configuration-service.sh`

## Validate the instaltion of TAP 

1. Using your web browser go to [https://tap-gui.tap.local.tanzu.ca](https://tap-gui.tap.local.tanzu.ca) 
   if you picked a different base domain use that. You will get warning from browser because the 
   install is using a self signed certificate ignore those warnings.

2. Login into the tap-gui using your github id. If you have issues here it is probably beacuse the 
   GitHub OAuth app is misconfigured or you don't have the correct client-id and secret. Check those
   configuration settings and try again.

3. The `dev` folder contains a namespace labled for TAP namespace provisioner. run 
   `kubectl apply -f dev/namespace.yaml` to create the namespace 

4. Deploy a demo workload open the file `dev/workload.yaml` and follow the instructions in the comments
   at the bottom of the file. The first time you delpoy a workload it will take more time while things 
   are initalized and warmed up. 

5. When the deploy is done, you can registry the software catalog entity for it using the url 
   `https://github.com/asaikali/tanzu-java-web-app/blob/main/catalog/catalog-info.yaml` or your own
   catalog entry. Ater registeration you can navigate to the app in the software catalog and everything
   should work just fine such as app live view ... etc.

## Debug the Installation 

There are a set of scripts starting in the 20 range that you can use to debug the state of the 
installation. 

1. `20-debug-watch-package-installs.sh` puts a watch on the pagkage installs you can use it to monitor
   progress or deletion of a tap cluster.

2. `21-debug-dump-all-kuberentes-objects.sh` prints out every kuberentes object in the cluster other than
   events and objects in the system namespacese that sart with `kube` in thier name.

3. `22-debug-dump-package-bundles.sh` will dump out all the carvel packages that are part of the tap 
   package repository or any other package repository in the `tap-install` namespace. The packages are
   written to `workspace/packages` folder. When you run into issues during the install inspecting the 
   source code in the carvel package can help you understand the root cause of the issue you are 
   troubleshooting.

4. `23-debug-dump-cartographer-objects.sh` will dump out all the components of the supply chain 
   configured on the tap installation. You can aslo look at the source code of the supply chains
   in the `workspace/packages` folder by locating the packages of the supply chain you are 
   interestend in.

## Delete the installation 

1. You can delete the install by running the script `30-delete-tap.sh` or if you prefer you can 
   just reset the Kuberentes cluster in docker desktop. 

## Resources 

* [Tanzu Application Platform Docs](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/index.html)
* [Carvel Website](https://carvel.dev/)
* [Cartographer](https://cartographer.sh/)
* [Crossplane](https://www.crossplane.io/)
* [Backstage](https://backstage.io/)

    