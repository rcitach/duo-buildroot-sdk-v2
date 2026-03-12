.PHONY: memory-map

CVI_BOARD_MEMMAP_H_PATH := ${BUILD_PATH}/output/${PROJECT_FULLNAME}/cvi_board_memmap.h
CVI_BOARD_MEMMAP_CONF_PATH := ${BUILD_PATH}/output/${PROJECT_FULLNAME}/cvi_board_memmap.conf
CVI_BOARD_MEMMAP_LD_PATH:= ${BUILD_PATH}/output/${PROJECT_FULLNAME}/cvi_board_memmap.ld
CVI_BOARD_MEMMAP_TXT_PATH= ${BUILD_PATH}/output/${PROJECT_FULLNAME}/cvi_board_memmap.txt

BOARD_MMAP_PATH := ${BORAD_FOLDER_PATH}/memmap.py
MMAP_CONV_PY := ${BUILD_PATH}/scripts/mmap_conv.py
MMAP_DISPLAY_PY := ${BUILD_PATH}/scripts/memory_display.py

RTOS := none
ifeq ($(CONFIG_ENABLE_FREERTOS),y)
	RTOS := freertos
else ifeq ($(CONFIG_ENABLE_RTTHREAD),y)
	RTOS := rtthread
endif

${CVI_BOARD_MEMMAP_H_PATH}: ${BOARD_MMAP_PATH} ${MMAP_CONV_PY}
	$(call print_target)
	mkdir -p $(dir $@)
	@${MMAP_CONV_PY} --type h --rtos ${RTOS} $< $@

${CVI_BOARD_MEMMAP_CONF_PATH}: ${BOARD_MMAP_PATH} ${MMAP_CONV_PY}
	$(call print_target)
	@mkdir -p $(dir $@)
	@${MMAP_CONV_PY} --type conf --rtos ${RTOS}  $< $@

${CVI_BOARD_MEMMAP_LD_PATH}: ${BOARD_MMAP_PATH} ${MMAP_CONV_PY}
	$(call print_target)
	@mkdir -p $(dir $@)
	@${MMAP_CONV_PY} --type ld --rtos ${RTOS}  $< $@

${CVI_BOARD_MEMMAP_TXT_PATH}: ${BOARD_MMAP_PATH} ${MMAP_DISPLAY_PY}
	$(call print_target)
	@mkdir -p $(dir $@)
	@${MMAP_DISPLAY_PY} --rtos ${RTOS} $< $@

ifeq ($(wildcard ${BOARD_MMAP_PATH}),)
memory-map:
else
memory-map: ${CVI_BOARD_MEMMAP_H_PATH} ${CVI_BOARD_MEMMAP_CONF_PATH} ${CVI_BOARD_MEMMAP_LD_PATH}
memory-map: ${CVI_BOARD_MEMMAP_TXT_PATH}
endif

ifeq ($(CONFIG_ENABLE_RTTHREAD),y)
	cp -rfv ${CVI_BOARD_MEMMAP_LD_PATH} ${RTTHREAD_PATH}/bsp/cvitek/c906_little/board/script/cv181x
endif
