# ubuntu-server-dev

Ubuntu Server cloud images packaged as a Docker container, intended for fast config management developer feedback loops

This is very clearly somewhat of an abuse of Docker, because Docker isn't really intended to run full operating systems. Something like [Incus](https://linuxcontainers.org/incus/) is a much better fit for this use-case - but many people will probably not have Incus installed and will therefore have a non-trivial time setting up a dev environment. Hence, Docker.

## :stop_sign: Security and support warning :rotating_light:

_**DO NOT USE THIS IN PRODUCTION.**_ I am really, really serious. Just say no.

This is intended for development environments ONLY. It does not come with any kind of support, including and especially security support. It may break at any time. Use at your own risk.

The goal is to allow for the creation of developer environments that simulate running Ubuntu VMs _just enough_ such that you can run e.g. Ansible against the (container) "hosts". It is an **explicit non-goal** to perfectly replicate the behavior of a production VM (after all, this is a container, not a VM, so this is basically impossible), so you need to have some kind of sandbox/staging environment to do serious testing in. The idea behind this image is to enable a fast development feedback loop locally, because usually testing against a sandbox environment is slow and/or causes conflicts when other people are trying to test as well.

## Install

<!-- TODO verify cause idrk how images are specified lol -->
```bash
$ docker pull ubuntu-server-dev
```

## Usage

```bash
$ id=$(docker run -d ubuntu-server-dev)
$ docker exec -it $id bash # You now are root inside a fully running Ubuntu Server container
```

## Building

You will need `buildah` and `podman`. You will also need to have `sudo` rights.

Then, run `./build.sh`.

## Author

AJ Jordan <alex@strugee.net>, <aj@seagl.org>

## License

Creative Commons Zero
