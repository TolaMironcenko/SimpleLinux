default: build_image

build_image:
	@sudo ./scripts/build_image.sh build

clean:
	@sudo ./scripts/build_image.sh clean

download_sources:
	@sudo ./scripts/build_image.sh download

build_rootfs:
	@sudo ./scripts/build_image.sh rootfs
