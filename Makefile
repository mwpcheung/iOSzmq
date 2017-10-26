export THEOS_DEVICE_IP = 192.168.0.141
export TARGET = iphone:latest:8.0
include $(THEOS)/makefiles/common.mk

TOOL_NAME = iAlg
CFLAGS += -Iinclude
CFLAGS += -std=c++11
iAlg_FILES = main.mm server.mm
LDFLAGS += lib/libzmq.a
include $(THEOS_MAKE_PATH)/tool.mk
