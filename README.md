# local-tap
This repository contains scripts to install Tanzu Application Platform (TAP) on 
Docker Desktop Kubernetes. It enables a single-user TAP deployment for experimentation 
and educational purposes. 

## Prerequisites

To complete the installation, you need to have the following ready:

0. Docker Desktop with Kubernetes turned on. You can probably use Minikube 
   if you wish. Contributions documenting how to use the scripts 
   in this repository with Minikube are welcome.

1. Username and password for the Tanzu Network that can be used to access the Tanzu 
   container registry where all the container images for TAP are stored. You need 
   to accept the EULA (see [docs](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/install-tanzu-cli.html))
   otherwise, your container image pulls will fail.

2. A container registry where you can publish container images, such as 
   [GitHub Packages](ghcr.io), [Google Artifact Registry](https://cloud.google.com/artifact-registry),
   [Azure Container Registry](https://azure.microsoft.com/en-us/products/container-registry), 
   or [Harbor](https://goharbor.io/).

3. A GitHub OAuth application configured to allow login to the TAP deployment.
   You will need the client ID and client secret.

4. A variety of common CLI tools installed. You probably have them. If not, you can 
   easily install them. `00-validate-clis-are-installed.sh` script checks your 
   system to see if it has the right CLIs installed.

5. (Optional) A DNS domain that points to 127.0.0.1. You can use *.local.tanzu.ca 
   if you don't have your own domain. By having a wildcard DNS entry that points back 
   to localhost, we can end up with a domain name such as tap-gui.tap.local.tanzu.ca 
   that works on the laptop running TAP on Docker Desktop. If you don't have 
   a DNS server, you can just use local.tanzu.ca.

### Common CLI Tools used in this repository

* [Carvel Tools](https://carvel.dev)
  * [imgpkg](https://carvel.dev/imgpkg/docs/latest) - image packaging utility
  * [ytt](https://carvel.dev/ytt/docs/latest) - templating and patching YAML
  * [kbld](https://carvel.dev/kbld/docs/latest) - image building and packing using SHA references
  * [kapp](https://carvel.dev/kapp/docs/latest) - k8s applications
* [Tanzu CLI](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/install-tanzu-cli.html) - Tanzu CLI tool
* [kubectl](https://kubernetes.io/docs/reference/kubectl/) - k8s CLI tool
* [jq](https://jqlang.github.io/jq/) - JSON CLI processor (querying and parsing)
* [socat](https://linux.die.net/man/1/socat) - SOcket CAT, multipurpose relay

### Installing CLI Tools on Mac using `brew`

```shell
brew tap vmware-tanzu/carvel
brew install ytt kbld kapp kwt imgpkg vendir kctrl
```

```shell
brew install kubernetes-cli
```

```shell
brew install jq
```

```shell
brew install socat
```

```shell
brew tap vmware-tanzu/carvel
brew install tanzu-cli
tanzu plugin install --group vmware-tap/default:v1.7.2
```

## How Networking Works When Deploying on Docker Desktop Kubernetes

By default, TAP deploys the Contour ingress controller using a Kubernetes LoadBalancer service.
To avoid problems with the LoadBalancer service on a dev machine running Docker Desktop or Minikube, 
we change the configuration of TAP to use a NodePort Service instead.

Once TAP is up and running, it will be exposed on two random port numbers selected by 
Kubernetes. You can run the script `05-proxy-traffic.sh`, which maps ports 80 and 443 
on your machine to the NodePort values selected by Kubernetes. The script uses 
the `socat` utility.

If you use the default `tap.local.tanzu.ca` base domain, then you can find the TAP GUI 
at [https://tap-gui.tap.local.tanzu.ca](https://tap-gui.tap.local.tanzu.ca).

## Deploy TAP on Docker Desktop Kubernetes

The installation process is done via a series of scripts located at the root of 
the repository. The scripts are idempotent; you can run them multiple times, and they 
should pick up where they left off.

1. Run the script `00-validate-clis-are-installed.sh` to check that all 
   the required CLIs are installed on your machine.

2. Copy the `config/settings-template.sh` file to `config/settings.sh`.

3. Edit the `config/settings.sh` file with your own values. There are many 
   comments in `settings.sh` to guide you along.

4. Run the script `01-validate-registry-access-and-credentials.sh` to check 
   that the TAP registry and the workload registry can be accessed from your machine.

5. Run the script `02-install-cluster-essentials.sh` to install kapp-controller 
   and SecretGen controller on your cluster.

6. Run the script `03-configure-tap-install-namespace.sh` to prepare the tap-install namespace.

7. Run the script `04-install-tap.sh` to install all the TAP packages. This will take 
   5 to 15 minutes depending on your internet connection speed and the amount of resources 
   available to your Docker Desktop Kubernetes. You can monitor progress by running the script 
   `20-debug-watch-package-installs.sh`.

8. When all the TAP packages are reconciled, run the script `05-proxy-traffic.sh` to 
   map ports 80 and 443 to the Contour ingress node ports.

9. Optionally, install Spring Cloud Gateway using the scripts `06-install-spring-cloud-gateway.sh` and 
   `07-install-application-configuration-service.sh`.

## Validate the Installation of TAP

1. Using your web browser, go to [https://tap-gui.tap.local.tanzu.ca](https://tap-gui.tap.local.tanzu.ca).
   If you picked a different base domain, use that. You will receive a warning from the browser because the 
   installation is using a self-signed certificate; ignore those warnings.

2. Log in to the TAP GUI using your GitHub ID. If you have issues here, it is probably because the 
   GitHub OAuth app is misconfigured, or you don't have the correct client ID and secret. Check those 
   settings and try again.

3. The `dev` folder contains a namespace labeled for TAP namespace provisioner. Run 
   `kubectl apply -f dev/namespace.yaml` to create the namespace.

4. To deploy a demo workload, open the file `dev/workload.yaml` and follow the instructions in the comments 
   at the bottom of the file. The first time you deploy a workload, it will take more time while things 
   are initialized and warmed up.

5. When the deployment is done, you can register the software catalog entity for it using the URL 
   `https://github.com/asaikali/tanzu-java-web-app/blob/main/catalog/catalog-info.yaml` or your own 
   catalog entry. After registration, you can navigate to the app in the software catalog, and everything 
   should work just fine, such as app live view, etc.

## Debug the Installation

There is a set of scripts starting in the 20 range that you can use to debug the state of the 
installation.

1. `20-debug-watch-package-installs.sh` puts a watch on the package installs; you can use it to monitor 
   the progress or deletion of a TAP cluster.

2. `21-debug-dump-all-kubernetes-objects.sh` prints out every Kubernetes object in the cluster other than 
   events and objects in the system namespaces that start with `kube` in their name.

3. `22-debug-dump-package-bundles.sh` will dump out all the Carvel packages that are part of the TAP 
   package repository or any other package repository in the `tap-install` namespace. The packages are 
   written to the `workspace/packages` folder. When you run into issues during the install, inspecting the 
   source code in the Carvel package can help you understand the root cause of the issue you are 
   troubleshooting.

4. `23-debug-dump-cartographer-objects.sh` will dump out all the components of the supply chain 
   configured on the TAP installation. You can also look at the source code of the supply chains 
   in the `workspace/packages` folder by locating the packages of the supply chain you are 
   interested in.

## Delete the Installation

1. You can delete the installation by running the script `30-delete-tap.sh`, or if you prefer, you can 
   just reset the Kubernetes cluster in Docker Desktop.

## Directory layout 

* `config/` contains configuration files for deploying tap 
* `dev/` contains sample workload and k8s yaml file to get started
* `workspace` used by the scripts to store temproary state, you will find mayn interesting thing is this folder as you run the scripts

## Resources

* [Tanzu Application Platform Docs](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/index.html)
* [Carvel Website](https://carvel.dev/)
* [Cartographer](https://cartographer.sh/)
* [Crossplane](https://www.crossplane.io/)
* [Backstage](https://backstage.io/)
