all: hello.efi

%.o: %.asm
	nasm -f win64 -o $@ $<

%.efi: %.o
	lld-link /subsystem:efi_application /entry:EfiMain /out:$@ $<

.PHONY: run
run: hello.efi
	../../devenv/run_qemu.sh hello.efi

clean:
	rm -f hello.efi
	rm -f disk.img
	rm -rf mnt
