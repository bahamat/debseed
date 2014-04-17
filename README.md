# Debian Preseeded Autoinstaller

This package will produce a Debian installer ISO that is fully unattended.

Just edit `preseed.txt` to taste, then run `make`.
Copy `autoinstall.iso` to your VM provisioning system or burn it to a CD/DVD.

On Linux the following are required:

* curl
* fuse
* mkisofs
* rsync

This works on Solaris as well, but the ISO needs to be extracted manually and requires root access.

    mkdir .mnt
    lofiadm -a ./debian-7.1.0-amd64-netinst.iso
    mount -o ro -F hsfs /dev/lofi/9 .mnt
    rsync -a -H --exclude=TRANS.TBL .mnt/ .autoinstall/
    umount .mnt
    rmdir .mnt
