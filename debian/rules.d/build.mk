# Because variables can be masked at anypoint by declaring
# PASS_VAR, we need to call all variables as $(call xx,VAR)
# This little bit of magic makes it possible:
xx=$(if $($(curpass)_$(1)),$($(curpass)_$(1)),$($(1)))

$(patsubst %,mkbuilddir-%,$(GLIBC_PASSES)) :: mkbuilddir-% : $(stamp)mkbuilddir-%
$(stamp)mkbuilddir-%: linux-kernel-headers/include/asm $(stamp)patch-stamp
	@echo Making builddir for $(curpass)
	test -d $(DEB_BUILDDIR) || mkdir $(DEB_BUILDDIR)
	touch $@

$(patsubst %,configure-%,$(GLIBC_PASSES)) :: configure-% : $(stamp)configure-%
$(stamp)configure-%: $(stamp)mkbuilddir-%
	@echo Configuring $(curpass)
	rm -f $(DEB_BUILDDIR)/configparms
	echo "CC = $(CC)"		>> $(DEB_BUILDDIR)/configparms
	echo "BUILD_CC = $(BUILD_CC)"	>> $(DEB_BUILDDIR)/configparms
	echo "CFLAGS = $(HOST_CFLAGS)"	>> $(DEB_BUILDDIR)/configparms
	echo "BUILD_CFLAGS = $(BUILD_CFLAGS)" >> $(DEB_BUILDDIR)/configparms
	echo "BASH := /bin/bash"	>> $(DEB_BUILDDIR)/configparms
	echo "KSH := /bin/bash"		>> $(DEB_BUILDDIR)/configparms
	echo "mandir = $(mandir)"	>> $(DEB_BUILDDIR)/configparms
	echo "infodir = $(infodir)"	>> $(DEB_BUILDDIR)/configparms
	echo "libexecdir = $(libexecdir)" >> $(DEB_BUILDDIR)/configparms
	echo "LIBGD = no"		>> $(DEB_BUILDDIR)/configparms
	echo "sysconfdir = /etc"	>> $(DEB_BUILDDIR)/configparms
	echo "rootsbindir = /sbin"	>> $(DEB_BUILDDIR)/configparms
# FIXME - Remove this linux'ism.
ifneq ($(DEB_HOST_GNU_SYSTEM),linux)
	echo "slibdir = /lib"		>> $(DEB_BUILDDIR)/configparms
endif

	cd $(DEB_BUILDDIR) && $(DEB_SRCDIR)/configure \
		--host=$(call xx,configure_target) \
		--build=$(DEB_BUILD_GNU_TYPE) --prefix=/usr --without-cvs \
		--enable-add-ons="$(call xx,add-ons)" \
		$(call xx,with_headers) $(call xx,extra_config_options) 2>&1 | tee -a $(log_build)

	touch $@

$(patsubst %,build-%,$(GLIBC_PASSES)) :: build-% : $(stamp)build-%
$(stamp)build-%: $(stamp)configure-%
	@echo Building $(curpass)
	$(MAKE) -C $(DEB_BUILDDIR) 2>&1 | tee -a $(log_build)
	touch $@

$(patsubst %,check-%,$(GLIBC_PASSES)) :: check-% : $(stamp)check-%
$(stamp)check-%: $(stamp)build-%
	@echo Testing $(curpass)
	@echo $(MAKE) -C $(DEB_BUILDDIR) check 2>&1 | tee -a $(log_test)
	touch $@

$(patsubst %,install-%,$(GLIBC_PASSES)) :: install-% : $(stamp)install-%
$(stamp)install-%: $(stamp)check-%
	@echo Installing $(curpass)
	rm -rf $(CURDIR)/debian/tmp-$(curpass)
	$(MAKE) -C $(DEB_BUILDDIR) install_root=$(CURDIR)/debian/tmp-$(curpass) install
	touch $@
