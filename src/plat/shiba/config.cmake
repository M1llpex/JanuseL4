#
# Copyright 2025, Millpex
#
# SPDX-License-Identifier: BSD-2-Clause
#

# Declare the platform and the architecture it supports
declare_platform(shiba KernelPlatShiba PLAT_SHIBA KernelSel4ArchAarch64)
set(KernelPlatform shiba CACHE STRING "seL4 platform")

# This block is only processed when 'shiba' is the selected platform
if(KernelPlatShiba)
    declare_seL4_arch(aarch64)
    set(KernelArmGicV3 ON)
    set(KernelArmCortexA72 ON)
    set(KernelArchArmV8a ON)
    config_set(KernelARMPlatform ARM_PLAT shiba)
    config_set(KernelArmMach MACH "google")

    list(APPEND KernelDTSList "src/plat/shiba/pixel8.dts")
    
    declare_default_headers(
        TIMER_FREQUENCY 100000000
        MAX_IRQ 512
        NUM_PPI 32
        KERNEL_TIMER_IRQ 27
        INTERRUPT_CONTROLLER arch/machine/gic_v3.h
        TIMER drivers/timer/arm_generic.h
        CLK_MAGIC 2951479051793528259llu
        CLK_SHIFT 64u
        KERNEL_WCET 10u
        TIMER_PRECISION 0
        TIMER_OVERHEAD_TICKS 0
        IRQ_SLOT_BITS 10
    )
endif()

# 5. Add the necessary source files for the drivers we declared (like the GICv3)
add_sources(
    DEP "KernelPlatformShiba"
    CFILES src/arch/arm/machine/gic_v3.c src/arch/arm/machine/l2c_nop.c src/plat/shiba/src/hardware.c src/plat/shiba/src/cache.c src/plat/shiba/src/gic.c src/plat/shiba/src/serial.c src/plat/shiba/src/smp.c
)
