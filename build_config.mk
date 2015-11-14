#
# Common build configuration for STM32.
#



AS = arm-none-eabi-gcc
CC = arm-none-eabi-gcc
CXX = arm-none-eabi-g++
GDB = arm-none-eabi-gdb
OBJCOPY = arm-none-eabi-objcopy
# A mixed C/C++ project requires linking to be done with C++ awareness.
LD = arm-none-eabi-g++
SIZE = arm-none-eabi-size
OOCD = openocd

# File for gdb programing session
GDB_INIT = $(ROOT_DIR)/tools/gdbinit

# Define the CPU
BOARD_FLAGS= -mthumb -mcpu=cortex-m4


LDFLAGS += \
	-Wl,-T,linker_file.ld \
	-Wl,--entry,ResetISR \
	-Wl,--gc-sections \


# The define __STRICT_ANSI__ has been introduced for "(GNU Tools for ARM
# Embedded Processors) 4.8.3 20131129 (release) [ARM/embedded-4_8-branch
# revision 205641]". Its stdio.h would export a dprintf function otherwise.
DEFINES += -D__STRICT_ANSI__ -Dcc3200 -Dgcc \
			-DSL_PLATFORM_MULTI_THREADED -DUSE_FREERTOS


INCLUDES += \
	-Iinc \
	-Icc3200-sdk \
	-Icc3200-sdk/driverlib \
	-Icc3200-sdk/driverlib/inc \
	-Icc3200-sdk/example/common \
	-Icc3200-sdk/inc \
	-Icc3200-sdk/oslib \
	-Icc3200-sdk/simplelink \
	-Icc3200-sdk/simplelink/include \
	-Icc3200-sdk/third_party/FreeRTOS \
	-Icc3200-sdk/third_party/FreeRTOS/source \
	-Icc3200-sdk/third_party/FreeRTOS/source/include \
	-Icc3200-sdk/third_party/FreeRTOS/source/portable/GCC/ARM_CM4 \
	-Icc3200-sdk/ti_rtos/ti_rtos_config/ewarm/iar/tirtos \


gdb_program:
	$(GDB) -x $(GDB_INIT) $(TARGET_NAME)$(TARGET_SUFFIX)
