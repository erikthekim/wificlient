include $(TOPDIR)/rules.mk

# Name, version and release number
# The name and version of your package are used to define the variable to point to the build directory of your package: $(PKG_BUILD_DIR)
PKG_NAME:=wificlient
PKG_VERSION:=1.0
PKG_RELEASE:=1

# Source settings (i.e. where to find the source codes)
# This is a custom variable, used below
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_MAINTAINER:=Erik Kim <erikkima13@gmail.com>
PKG_LICENSE:=GPL-2.0
SOURCE_DIR:=/home/erik/Projects/cloudwifi/openwrt/package/custom/wificlient
#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=file://$(SOURCE_DIR)/
#PKG_HASH :=b5726d42d887d4e7491787bbc4fc7e3e4d8a66229f5fbe6c635044d7bc3b6cd1
#HOST_BUILD_DEPENDS:=ruby/host
#PKG_BUILD_DEPENDS:=ruby/host
#PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
#include $(INCLUDE_DIR)/host-build.mk

# Package definition; instructs on how and where our package will appear in the overall configuration menu ('make menuconfig')
define Package/wificlient
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Wificlient
  DEPENDS:=+ruby
endef

# Package description; a more verbose description on what our package does
define Package/wificlient/description
  A Wificlient module for our project.
endef

# Package preparation instructions; create the build directory and copy the source code. 
# The last command is necessary to ensure our preparation instructions remain compatible with the patching system.
define Build/Prepare
		mkdir -p $(PKG_BUILD_DIR)
		rsync -a $(SOURCE_DIR)/src/ $(PKG_BUILD_DIR)
		mkdir -p $(PKG_BUILD_DIR)/files
		${CP} $(SOURCE_DIR)/Gemfile $(PKG_BUILD_DIR)/Gemfile
		rsync -a $(SOURCE_DIR)/.gems/ $(PKG_BUILD_DIR)/.gems
		export GEM_HOME=$(PKG_BUILD_DIR)/.gems
		export GEM_PATH=$(PKG_BUILD_DIR)/.gems
		$(Build/Patch)
		echo "preparing..."
endef

define Build/Configure
		echo "configuring..."
endef
# Package build instructions; invoke the target-specific compiler to first compile the source file, and then to link the file into the final executable
define Build/Compile
		
		cd $(PKG_BUILD_DIR)
		
		# Ensure the Ruby script is executable
		chmod +x $(PKG_BUILD_DIR)/wifi_state_machine.rb
		echo "compiling..."

endef

# Package install instructions; create a directory inside the package to hold our executable, and then copy the executable we built previously into the folder
define Package/wificlient/install
		echo "installing..."
		$(INSTALL_DIR) $(1)/bin
		$(INSTALL_BIN) $(PKG_BUILD_DIR)/wifi_state_machine.rb $(1)/bin
		${CP} $(PKG_BUILD_DIR)/Gemfile $(1)/bin/Gemfile
		rsync -a $(PKG_BUILD_DIR)/.gems/ $(1)/bin/.gems
		rsync -a $(PKG_BUILD_DIR)/files/ $(1)/bin/files
		${CP} $(PKG_BUILD_DIR)/hostapd.conf $(1)/bin/files/hostapd.conf
		${CP} $(PKG_BUILD_DIR)/hostapd.wpa_pmk_file $(1)/bin/files/hostapd.wpa_pmk_file
endef

# This command is always the last, it uses the definitions and variables we give above in order to get the job done
$(eval $(call BuildPackage,wificlient))
