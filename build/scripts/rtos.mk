CROSS_COMPILE_PATH_64_BIN_RISCV64_RTT_L := ${TOP_DIR}/host-tools/gcc/riscv64-elf-x86_64
RTOS_NAME := $(strip $(if $(CONFIG_ENABLE_FREERTOS),freertos,$(if $(CONFIG_ENABLE_RTTHREAD),rtthread,)))

define FREERTOS_BUILD
	@cd ${FREERTOS_PATH}/cvitek && ./build_cv181x.sh || exit 1
endef

define RTTHREAD_BUILD
	cd ${RTTHREAD_PATH}/bsp/cvitek/c906_little && \
		RTT_EXEC_PATH=${CROSS_COMPILE_PATH_64_BIN_RISCV64_RTT_L}/bin \
		scons -j8
endef

RTOS_BUILD_CMD := $(if $(CONFIG_ENABLE_FREERTOS),$(FREERTOS_BUILD),$(if $(CONFIG_ENABLE_RTTHREAD),$(RTTHREAD_BUILD),))

rtos: memory-map
	$(call print_target)
ifeq ($(CHIP_ARCH_L),$(filter $(CHIP_ARCH_L), cv180x))
	cd ${FREERTOS_PATH}/cvitek && ./build_cv180x.sh || exit 1
else
	$(if $(RTOS_BUILD_CMD),$(RTOS_BUILD_CMD),$(error Please enable CONFIG_ENABLE_FREERTOS or CONFIG_ENABLE_RTTHREAD))
endif

rtos-clean:
	$(call print_target)
ifeq (${CONFIG_ENABLE_FREERTOS},y)
	cd ${FREERTOS_PATH}/cvitek && rm -rf build install
else ifeq ($(CONFIG_ENABLE_RTTHREAD),y)
	cd ${RTTHREAD_PATH}/bsp/cvitek/c906_little && \
		RTT_EXEC_PATH=${CROSS_COMPILE_PATH_64_BIN_RISCV64_RTT_L}/bin \
		scons -c
endif
