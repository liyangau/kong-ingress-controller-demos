
# ██╗░░██╗░█████╗░███╗░░██╗░██████╗░  ██╗░░██╗░█████╗░░██████╗  ██████╗░███████╗███╗░░░███╗░█████╗░
# ██║░██╔╝██╔══██╗████╗░██║██╔════╝░  ██║░██╔╝██╔══██╗██╔════╝  ██╔══██╗██╔════╝████╗░████║██╔══██╗
# █████═╝░██║░░██║██╔██╗██║██║░░██╗░  █████═╝░╚█████╔╝╚█████╗░  ██║░░██║█████╗░░██╔████╔██║██║░░██║
# ██╔═██╗░██║░░██║██║╚████║██║░░╚██╗  ██╔═██╗░██╔══██╗░╚═══██╗  ██║░░██║██╔══╝░░██║╚██╔╝██║██║░░██║
# ██║░╚██╗╚█████╔╝██║░╚███║╚██████╔╝  ██║░╚██╗╚█████╔╝██████╔╝  ██████╔╝███████╗██║░╚═╝░██║╚█████╔╝
# ╚═╝░░╚═╝░╚════╝░╚═╝░░╚══╝░╚═════╝░  ╚═╝░░╚═╝░╚════╝░╚═════╝░  ╚═════╝░╚══════╝╚═╝░░░░░╚═╝░╚════╝░

KONG_INGRESS_VERSION=latest
KONG_INGRESS_DOWNLOAD_LINK=https://raw.githubusercontent.com/Kong/kubernetes-ingress-controller/$(if $(filter latest,$(KONG_INGRESS_VERSION)),main,v$(KONG_INGRESS_VERSION))/deploy/single/all-in-one-postgres.yaml

####################################################################################
# Cluster Creation
# This will create a single node cluster `Kong`
####################################################################################
.PHONY: cluster-up
cluster-up:
	kind create cluster --name kong

.PHONY: cluster-down
cluster-down:
	kind delete cluster --name kong

####################################################################################
# CE Demo
####################################################################################
.PHONY: kong-install
kong-install: kong/kong-install-manifest-$(KONG_INGRESS_VERSION).yaml
	kubectl kustomize kong/overlays/ | kubectl apply -f -
	kubectl apply -f demos/httpbin.yaml
	kubectl -n kong rollout status deployment ingress-kong

.PHONY: kong-uninstall
kong-uninstall: kong/kong-install-manifest-$(KONG_INGRESS_VERSION).yaml
	kubectl kustomize kong/overlays/ | kubectl delete -f -
	kubectl delete -f demos/httpbin.yaml

.PHONY: kong-install-manifest
kong/kong-install-manifest-$(KONG_INGRESS_VERSION).yaml:
	wget $(KONG_INGRESS_DOWNLOAD_LINK) -O kong/base/kong-install-manifest.yaml