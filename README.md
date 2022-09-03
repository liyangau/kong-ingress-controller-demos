# Kong Ingress Demo

This is a collection of scripts/manifests designed to show case how Kong Ingress controller works with plugins.

## How it works:

Currently I have created demos for below plugins.

- [ACL](/demos/acl)
- [Basic Auth](/demos/basic-auth)
- [HMAC Auth](/demos/hmac-auth)
- [JWT](/demos/jwt)
- [Key Auth](/demos/key-auth)
- [Oauth2](/demos/oauth2-auth)

You can go to each folder (for example `demos/acl`). Run `make install` to apply the manifest, `make test` to test the flow and `make uninstall` to clean up.

## Getting Started

### Dependencies

This repo assumes you have the following tools installed:

- [Make](https://man7.org/linux/man-pages/man1/make.1.html)
- [Kind](https://kind.sigs.k8s.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [jq](https://stedolan.github.io/jq/)
- [curl](https://curl.haxx.se/)
- [openssl](https://www.openssl.org/)

**Note** This repo has been tested on Debian and MacOS.

### Start up and install

Starting a KIND cluster:

```bash
make cluster-up
```

Installing Kong and httpbin (in default namespace):

```bash
make kong-install
```

You should now have a fully functioning Kong Ingress Installed now.

To validate:

```bash
❯ kubectl get pod -n kong

NAME                            READY   STATUS      RESTARTS   AGE
ingress-kong-7ddc965575-46jdp   2/2     Running     0          9m28s
kong-migrations-p5qsq           0/1     Completed   0          9m28s
postgres-0                      1/1     Running     0          9m28s
```

## Delete cluster

To delete the cluster, we can run below command.

```bash
make cluster-down
```

## Resources

- [Kong Ingress Controller](https://docs.konghq.com/kubernetes-ingress-controller/latest/)