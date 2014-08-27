DEBIAN_VERSION=7.6.0
ARCH=amd64

INSTALLERBASEIMAGE=debian-$(DEBIAN_VERSION)-$(ARCH)-netinst.iso
URL=http://cdimage.debian.org/debian-cd/$(DEBIAN_VERSION)/$(ARCH)/iso-cd

CURL=curl
CURLFLAGS=--location --progress-bar
GENISOIMAGEFLAGS=-r -J -no-emul-boot -boot-load-size 4 -boot-info-table -b isolinux/isolinux.bin -c isolinux/boot.cat ./.autoinstall
RSYNC=rsync
RSYNCFLAGS=-a -H --exclude=TRANS.TBL

UNAME=$(shell uname)

ifeq ($(UNAME),Linux)
GENISOIMAGE=genisoimage
MOUNT=fuseiso $< .mnt
UNMOUNT=fusermount -u .mnt
endif
ifeq ($(UNAME),SunOS)
GENISOIMAGE=mkisofs
MOUNT=mount -o ro -F hsfs $$(lofiadm -a ./$<) .mnt
UNMOUNT=umount .mnt ; lofiadm -d ./$<
endif

autoinstall.iso: .autoinstall/preseed.txt .autoinstall/isolinux/isolinux.cfg
	$(GENISOIMAGE) -o $@ $(GENISOIMAGEFLAGS)

.autoinstall/preseed.txt: preseed.txt .autoinstall/md5sum.txt
	cp $< $@

.autoinstall/isolinux/isolinux.cfg: isolinux.cfg .autoinstall/md5sum.txt
	cp $< $@

.autoinstall/md5sum.txt: $(INSTALLERBASEIMAGE)
	mkdir .mnt
	$(MOUNT)
	$(RSYNC) $(RSYNCFLAGS) .mnt/ .autoinstall/
	chmod -R +w .autoinstall
	$(UNMOUNT)
	rmdir .mnt
	touch $@

$(INSTALLERBASEIMAGE):
	$(CURL) $(CURLFLAGS) --output $@ $(URL)/$@

clean:
	$(RM) -r .autoinstall autoinstall.iso $(INSTALLERBASEIMAGE)
