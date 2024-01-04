#---- Environment Settings ---------------------------------

# Tailscale creds for k8s operator this shoud be created on the tailscale admin
# page. Create the client with Devices write scope and the tag tag:k8s-operator.
#

readonly TAILSCALE_CLIENT_ID=
readonly TAILSCALE_CLIENT_SECRET=
readonly TAILSCALE_HOSTNAME="docker-worklaptop"

readonly CLUSTER_ESSENTIALS_BUNDLE=tanzu-cluster-essentials-bundle-1.7.2.yml

#---- DNS Settings --------------------------------------
readonly BASE_DOMAIN="local.tanzu.ca"

#---- Tanzunet Settings --------------------------------------

# During the install process we will need to download software packages from 
# the Tanzu network so you need to define environment variables to provide the 
# creds that the scripts can use to access the tanzu network. The API token 
# can be obtained from your Tanzu Network Account page.  You can put the 
# env vars in script that you can run before you run any of the scripts 
# in this repo. 

readonly TANZU_NET_USERNAME=
readonly TANZU_NET_PASSWORD=

#---- Software Versions  -----------------------

#
# Select the version of TAP to install
#
readonly TAP_VERSION=1.7.2