THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
ARCHS = armv7 arm64
TARGET = iphone:latest:7.0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = hook
hook_FILES = $(wildcard src/*.m) src/Tweak.xm
hook_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
hook_FRAMEWORKS = UIKit Foundation CFNetwork Security

after-install::
	install.exec "killall -9 WeChat"
