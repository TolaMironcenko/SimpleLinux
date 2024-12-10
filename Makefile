default: build_image

build_image:
	./scripts/build_image.sh build

source:
	./scripts/build_image.sh download

download:
	./scripts/build_image.sh download

clean:
	./scripts/clean.sh

distclean:
	./scripts/clean.sh
	if [ -d downloads ]; then \
		rm -rv downloads; \
	fi

dropbear:
	./scripts/build_image.sh dropbear

sdroot_usable:
	./scripts/build_image.sh sdroot_usable
