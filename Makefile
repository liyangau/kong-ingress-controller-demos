# ___   _  _______  __    _  _______    ______   _______  __   __  _______
#|   | | ||       ||  |  | ||       |  |      | |       ||  |_|  ||       |
#|   |_| ||   _   ||   |_| ||    ___|  |  _    ||    ___||       ||   _   |
#|      _||  | |  ||       ||   | __   | | |   ||   |___ |       ||  | |  |
#|     |_ |  |_|  ||  _    ||   ||  |  | |_|   ||    ___||       ||  |_|  |
#|    _  ||       || | |   ||   |_| |  |       ||   |___ | ||_|| ||       |
#|___| |_||_______||_|  |__||_______|  |______| |_______||_|   |_||_______|
#

KONG_INGRESS_VERSION=1.1.0
KONG_INGRESS_DOWNLOAD_LINK=https://raw.githubusercontent.com/Kong/kubernetes-ingress-controller/$(KONG_INGRESS_VERSION)/deploy/single/all-in-one-postgres.yaml
KONG_INGRESS_INSTALL_MANIFEST=kong/kong-install-manifest-$(KONG_INGRESS_VERSION).yaml

KONG_INGRESS_EE_DBLESS_DOWNLOAD_LINK=https://raw.githubusercontent.com/Kong/kubernetes-ingress-controller/$(KONG_INGRESS_VERSION)/deploy/single/all-in-one-dbless-k4k8s-enterprise.yaml 
KONG_INGRESS_EE_DBLESS_INSTALL_MANIFEST=kong/kong-install-manifest-$(KONG_INGRESS_VERSION).yaml

####################################################################################
# Cluster Creation
# This will map the host 8001 to NodePort 32001 and 
# host 8002 to NodePort 32002
####################################################################################
.PHONY: k3d-up
k3d-up:
	k3d cluster create \
	  --k3s-server-arg '--no-deploy=traefik' \
	  --api-port 6443 \
	  -p "8001-8002:32001-32002/TCP@server[0]" \
	  	kong

.PHONY: k3d-down
k3d-down:
	k3d cluster delete kong

####################################################################################
# CE Demo
####################################################################################
.PHONY: kong-install
kong-install: kong/kong-install-manifest-$(KONG_INGRESS_VERSION).yaml
	kustomize build kong/overlays/ | kubectl apply -f -
	kubectl apply -f demos/httpbin.yaml

.PHONY: kong-uninstall
kong-uninstall: kong/kong-install-manifest-$(KONG_INGRESS_VERSION).yaml
	kustomize build kong/overlays/ | kubectl delete -f -
	kubectl delete -f demos/httpbin.yaml

.PHONY: kong-install-manifest
kong/kong-install-manifest-$(KONG_INGRESS_VERSION).yaml:
	wget $(KONG_INGRESS_DOWNLOAD_LINK) -O kong/base/kong-install-manifest.yaml

####################################################################################
# Enterprise without license Demo
####################################################################################
.PHONY: kong-ee-dbless-install
kong-ee-dbless-install: kong/kong-ee-dbless-install-manifest-$(KONG_INGRESS_VERSION).yaml
	kustomize build kong-ee-dbless/overlays/ | kubectl apply -f -
	kubectl apply -f demos/echo.yaml

.PHONY: kong-ee-dbless-uninstall
kong-ee-dbless-uninstall: kong/kong-ee-dbless-install-manifest-$(KONG_INGRESS_VERSION).yaml
	kustomize build kong-ee-dbless/overlays/ | kubectl delete -f -
	kubectl delete -f demos/httpbin.yaml

.PHONY: kong-ee-dbless-install-manifest
kong/kong-ee-dbless-install-manifest-$(KONG_INGRESS_VERSION).yaml:
	wget $(KONG_INGRESS_EE_DBLESS_DOWNLOAD_LINK) -O kong-ee-dbless/base/kong-install-manifest.yaml

####################################################################################
# Enterprise with license Demo
####################################################################################
# .PHONY: kong-ee-dbless-install
# kong-ee-dbless-install: kong/kong-ee-dbless-install-manifest-$(KONG_INGRESS_VERSION).yaml
# 	kubectl create namespace kong
# 	kubectl create secret generic kong-enterprise-license --from-file=license=kong-ee-dbless/license -n kong
# 	kustomize build kong-ee-dbless/overlays/ | kubectl apply -f -
#	kubectl apply -f demos/httpbin.yaml

# .PHONY: kong-ee-dbless-uninstall
# kong-ee-dbless-uninstall: kong/kong-ee-dbless-install-manifest-$(KONG_INGRESS_VERSION).yaml
# 	kustomize build kong-ee-dbless/overlays/ | kubectl delete -f -
# 	kubectl delete secret -n kong kong-enterprise-license
#	kubectl delete -f demos/httpbin.yaml

# .PHONY: kong-ee-dbless-install-manifest
# kong/kong-ee-dbless-install-manifest-$(KONG_INGRESS_VERSION).yaml:
# 	wget $(KONG_INGRESS_EE_DBLESS_DOWNLOAD_LINK) -O kong-ee-dbless/base/kong-install-manifest.yaml