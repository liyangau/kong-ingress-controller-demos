# Kong Ingress Demo

This is a collection of scripts designed to show case how the Kong Ingress works and how to configure it.

## How it works:

In each directory in `demos/` you will find a `manifest.yaml`, in the corresponding `README.md` you will find a description of what the configuration for that directory does. You will notice some steps depend on you having run previous steps. The dependencies will be listed in the `README.md`

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

You should now have a fully functioning Kong Ingress Install, to validate:

```bash
❯ kubectl get pod -n kong

NAME                            READY   STATUS      RESTARTS   AGE
ingress-kong-7ddc965575-46jdp   2/2     Running     0          9m28s
kong-migrations-p5qsq           0/1     Completed   0          9m28s
postgres-0                      1/1     Running     0          9m28s
```

## Authentication Demos:

- [ACL](/demos/acl)
- [Basic Auth](/demos/basic-auth)
- [HMAC Auth](/demos/hmac-auth)
- [JWT](/demos/jwt)
- [Key Auth](/demos/key-auth)
- [Oauth2](/demos/oauth2-auth)


## Clean Up

to remove everything just run

```bash
make cluster-down
```
This will destroy the cluster.

## Resources

- [Kong Ingress Controller](https://docs.konghq.com/kubernetes-ingress-controller/)