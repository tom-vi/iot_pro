.PHONY: all

# Build root. For being compatible with Cygwin and a pure Windows
# arm-none-eabi-gcc we can not use absolute paths. Luckily a relative path
# works for our setup too.
ROOT_DIR = .

# Target filename
TARGET_NAME = Firmware
TARGET_SUFFIX = .axf
#
# Use all as default Target
#
all:

include build_config.mk


DRIVER += \
	$(ROOT_DIR)/cc3200-sdk/simplelink/gcc/exe/libsimplelink.a \
	$(ROOT_DIR)/cc3200-sdk/driverlib/gcc/exe/libdriver.a \
	$(ROOT_DIR)/cc3200-sdk/oslib/gcc/exe/FreeRTOS.a \
#$(ROOT_DIR)/cc3200-sdk/oslib/gcc/exe/libtirtos.a

OBJS += \
	src/bma222drv.o \
	src/device_status.o \
	src/main.o \
	src/pinmux.o \
	src/smartconfig.o \
	src/tmp006drv.o \
	cc3200-sdk/example/common/gpio_if.o \
	cc3200-sdk/example/common/i2c_if.o \
	cc3200-sdk/example/common/startup_gcc.o \
	cc3200-sdk/example/common/uart_if.o \


DEPS := $(OBJS:.o=.d)

OPTIMIZATION_FLAG = -Og
DEBUG_FLAGS = -g
DEP_FLAGS = -MMD
WARN_FLAGS = -W -Wall


COMMON_FLAGS += \
	$(BOARD_FLAGS) \
	$(WARN_FLAGS) \
	$(DEBUG_FLAGS) \
	$(DEP_FLAGS) \
	$(INCLUDES) \
	$(DEFINES) \

#
# The flags passed to the assembler.
#
AFLAGS += \
	$(COMMON_FLAGS) \
	-x assembler-with-cpp \

#
# The flags passed to the c compiler.
#
CFLAGS=-mthumb \
$(COMMON_FLAGS) \
		-ffunction-sections \
		-fdata-sections \
		-std=c99 \
#-lm \

#
# The flags passed to the c++ compiler
#
CXXFLAGS += \
	$(COMMON_FLAGS) $(OPTIMIZE_FLAGS) \
	-std=c++11 \
	-ffunction-sections -fdata-sections \

#
# The flags passed to the linker
#
LDFLAGS += \
	$(BOARD_FLAGS) \
	-lc \
	-lm \

clean:
	rm -f $(OBJS)
	rm -f $(DEPS)

realclean: clean
	rm -f $(TARGET_NAME)$(TARGET_SUFFIX)
	rm -f $(TARGET_NAME).bin

ultraclean: realclean
	rm -f openocd.log

all:   $(OBJS)  
	$(LD) $(LDFLAGS) -o $(TARGET_NAME)$(TARGET_SUFFIX) $(filter %.o %.a, ${^}) $(DRIVER)
	$(SIZE) $(TARGET_NAME)$(TARGET_SUFFIX)
	$(OBJCOPY) -O binary $(TARGET_NAME)$(TARGET_SUFFIX) $(TARGET_NAME).bin

# Default rules for building object files from the different type of source
# files.
%.o:    %.c
	$(CC) -c $(CFLAGS) -o $@ $<

%.o:    %.cpp
	$(CXX) -c $(CXXFLAGS) -o $@ $<

%.o:    %.s
	$(AS) -c $(ASFLAGS) -o $@ $<


# Include dependencies at the very end so that they will not mess up our
# make targets.
-include $(DEPS)