#!/bin/sh

set -euo pipefail

trap 'echo failed' ERR

imgname=ubuntu-server-dev

# TODO verify this file
# TODO parameterize this by Ubuntu version, and tag appropriately
# TODO deal with checking for updates to this file, somehow
filename=ubuntu-24.04-server-cloudimg-amd64-root.tar.xz
wget --no-clobber https://cloud-images.ubuntu.com/releases/24.04/release/$filename

if ! [ $(id -u) = 0 ]; then
	# Need to be actual root to `mknod` things in /dev.
	# Being root obviates the need for `buildah unshare`, which throws errors because root is not in /etc/subuid.
	# https://github.com/containers/buildah/issues/1657#issuecomment-504737328
	echo 'Reexecuting under root...'
	sudo "$0" "$@"
	echo 'Tranferring to unprivileged user...'
	sudo podman save localhost/$imgname | podman load
	echo 'Cleaning up root user image...'
	sudo podman rmi localhost/$imgname
	exit 0
fi

newcontainer=$(buildah from scratch)

mnt=$(buildah mount $newcontainer)

# We extract from tar into a mount instead of using `buildah copy` to ensure as direct a path as possible into the final image, so that all these extra attributes are correctly created
tar --numeric-owner --preserve-permissions --same-owner --acls --selinux --xattrs -C $mnt -xvf $filename

# Disable TPM-related units, which fail at runtime in the container environment
chroot $mnt systemctl disable tpm-udev.path

# Slice rootfs config out of fstab, since LABEL=cloudimg-rootfs doesn't exist in the container environment and systemd-remount-fs.service complains about not being able to find it
chroot $mnt sed -i '/LABEL=cloudimg-rootfs/d' /etc/fstab

# Networking setup is expected to not actually cross a network boundary (i.e. only talk to the container host), so decrease the timeout because all operations here should be fast
mkdir $mnt/etc/systemd/system/systemd-networkd-wait-online.service.d/
cat > $mnt/etc/systemd/system/systemd-networkd-wait-online.service.d/override.conf <<EOF
[Service]
TimeoutSec=10s
EOF

buildah config --author='AJ Jordan' --arch=amd64 --cmd=/bin/systemd --created-by='https://github.com/SeaGL/ubuntu-server-dev' $newcontainer

buildah commit --rm $newcontainer $imgname
