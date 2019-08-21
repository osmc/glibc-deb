# configuration options for all flavours
CC = $(DEB_HOST_GNU_TYPE)-$(BASE_CC)-8
CXX = $(DEB_HOST_GNU_TYPE)-$(BASE_CXX)-8
libc = libc6.1

ifeq (,$(filter stage1 stage2, $(DEB_BUILD_PROFILES)))
# build an ev67 optimized library
GLIBC_PASSES += alphaev67
DEB_ARCH_REGULAR_PACKAGES += libc6.1-alphaev67
alphaev67_configure_target = alphaev67-linux-gnu
alphaev67_CC = $(CC) -mcpu=ev67 -mtune=ev67 
alphaev67_CXX = $(CXX) -mcpu=ev67 -mtune=ev67 
alphaev67_slibdir = /lib/$(DEB_HOST_MULTIARCH)/ev67
endif
