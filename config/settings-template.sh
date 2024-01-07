# Settigs file to deploy a local TAP on docker desktop kubernetes

#---- DNS Settings --------------------------------------
#
# This domain should be mapped to 127.0.0.1 in public DNS server
# using a wildcard for example in this case below *.local.tanzu.ca returns
# 127.0.0.1
#
readonly BASE_DOMAIN="tap.local.tanzu.ca"

#---- tanzu net settings ---------
#
# Tanzu container registry is used as the source of the all the packages
# to deploy tap. configure the creds to access tanzu net. 
#
readonly TANZU_NET_REGISTRY_HOST=registry.tanzu.vmware.com
readonly TANZU_NET_USERNAME=
readonly TANZU_NET_PASSWORD=

#----- workload registry settings ---
#
# Tanzu Build Service and the supply chain publish workload container images 
# to a container registry. Settings below are where workload images will be 
# published to
#
readonly WORKLOAD_REGISTRY_HOST=
readonly WORKLOAD_REGISTRY_USERNAME=
readonly WORKLOAD_REGISTRY_PASSWORD=
readonly WORKLOAD_REGISTRY_REPO=${WORKLOAD_REGISTRY_HOST}/tap

#---- TAP GUI Auth with GitHub Settings --------------------------------------

#
# Backstage based TAP GUI can login users with OpenID Connect, the scripts
# in this deployment configure TAP GUI to login users using thier GitHUB
# IDs you will need to provision a GitHub App in your developer settings
# on the https://github.com/settings/developers page. On the App setting 
# page set the app home page and callback urls to point the URL of where
# TAP GUI is running for example "https://tap-guit.tap.local.tanzu.ca" works
# if you are using the localhost based domain name from above. You will
# need to copy and paste the client id and secret from the Github settings
# page into these env vars so that TAP GUI can be configured correctly. 
# 

readonly GITHUB_CLIENT_ID=
readonly GITHUB_CLIENT_SECRET=

#---- Software Versions to install -----------------------
readonly CLUSTER_ESSENTIALS_LOCK_FILE=tanzu-cluster-essentials-bundle-1.7.2.yml
readonly TAP_VERSION=1.7.2


