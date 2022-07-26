# Hurricane <img align="right" src="https://user-images.githubusercontent.com/5100938/180940181-0067defc-cae1-4d7a-809b-96c742b9cf25.png">

Hurricane is a fork of [Typhoon](https://github.com/poseidon/typhoon) for ephemeral bare-metal setups.

Typhoon is a minimal and free Kubernetes distribution.

* Minimal, stable base Kubernetes distribution
* Declarative infrastructure and configuration
* Free (freedom and cost) and privacy-respecting
* Practical for labs, datacenters, and clouds

Typhoon distributes upstream Kubernetes, architectural conventions, and cluster addons, much like a GNU/Linux distribution provides the Linux kernel and userspace components.

## Features

* Kubernetes v1.24.3 (upstream)
* Single or multi-master, [Calico](https://www.projectcalico.org/) or [Cilium](https://github.com/cilium/cilium) or [flannel](https://github.com/coreos/flannel) networking
* On-cluster etcd with TLS, [RBAC](https://kubernetes.io/docs/admin/authorization/rbac/)-enabled, [network policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
* Advanced features like [snippets](https://typhoon.psdn.io/advanced/customization/#hosts) customization
* Ready for Ingress, Prometheus, Grafana, and other optional [addons](https://typhoon.psdn.io/addons/overview/)

## Docs

Please see the [official docs](https://typhoon.psdn.io) and the bare-metal [tutorial](https://typhoon.psdn.io/flatcar-linux/bare-metal/).

