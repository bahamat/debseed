INSTALLERBASEIMAGE=debian-7.1.0-amd64-netinst.iso

CURL=curl
CURLFLAGS=--location --progress-bar --output
MKISOFS=mkisofs
MKISOFSFLAGS=-r -J -no-emul-boot -boot-load-size 4 -boot-info-table -b isolinux/isolinux.bin -c isolinux/boot.cat ./.autoinstall
RSYNC=rsync
RSYNCFLAGS=-a -H --exclude=TRANS.TBL .mnt/ .autoinstall/

all: autoinstall.iso

$(INSTALLERBASEIMAGE):
	$(CURL) $(CURLFLAGS) $@

.autoinstall/isolinux/isolinux.bin: $(INSTALLERBASEIMAGE)
	# If running SunOS this step currently needs to be done manually with the following commands:
	# lofiadm -a ./debian-7.1.0-amd64-netinst.iso 
	# mount -o ro -F hsfs /dev/lofi/2 .mnt
	# rsync -a -H --exclude=TRANS.TBL .mnt/ .autoinstall/
	mkdir .mnt
	fuseiso $< .mnt
	rsync -a -H --exclude=TRANS.TBL /mnt/ ~/autoinstall/
	fusermount -u .mnt
	rmdir .mnt
	touch preseed.txt isolinux.cfg

.autoinstall/preseed.txt: preseed.txt
	cp $< $@

.autoinstall/isolinux/isolinux.cfg: isolinux.cfg
	cp $< $@

autoinstall.iso: .autoinstall/preseed.txt .autoinstall/isolinux/isolinux.cfg
	$(MKISOFS) -o $@ $(MKISOFSFLAGS)

clean:
	$(RM) .autoinstall autoinstall.iso $(INSTALLERBASEIMAGE)

.PHONY: all
