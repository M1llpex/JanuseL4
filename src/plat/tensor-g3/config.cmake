#
# Copyright 2025, Millpex
#
# SPDX-License-Identifier: GPL-2.0-only
#

# Declare the tensor-g3 platform for the aarch64 architecture.
declare_platform(tensor-g3 KernelPlatformTensorG3 PLAT_TENSORG3 KernelSel4ArchAarch64)

if(KernelPlatformTensorG3)

    # Set the correct architecture and CPU type based on dmesg.txt.
    declare_seL4_arch(aarch64)
    set(KernelArmCortexA72 ON)
    set(KernelArchArmV8A ON)

    # Enable the GICv3 interrupt controller, also confirmed by dmesg.txt.
    set(KernelArmGicV3 ON)

    # Set the platform identifier for the kernel.
    config_set(KernelARMPlatform ARM_PLAT tensor-g3)
    config_set(KernelArmMach MACH "google")
    # Add the platform's device tree file to the build.
    # Note: The incorrect dependency on rockpro64 has been removed.
    list(APPEND KernelDTSList "src/plat/tensor-g3/tensor-g3.dts")
    # Declare platform-specific constants.
    declare_default_headers(
        TIMER_FREQUENCY 24576000
        MAX_IRQ 992
        NUM_PPI 16
	KERNEL_TIMER_IRQ 30
        TIMER drivers/timer/arm_generic.h
        INTERRUPT_CONTROLLER arch/machine/gic_v3.h
	KERNEL_WCET 10u
        TIMER_PRECISION 8
        TIMER_OVERHEAD_TICKS 2
        IRQ_SLOT_BITS 11	
    )

endif()

# Add all the necessary source files for the tensor-g3 platform.
# This uses the correct file names and paths we established.
add_sources(
    DEP "KernelPlatformTensorG3"
    CFILES 
        src/plat/tensor-g3/src/serial.c
        src/plat/tensor-g3/src/timer.c
        src/plat/tensor-g3/src/gic.c
	src/plat/tensor-g3/src/cache.c
	src/arch/arm/machine/gic_v3.c
)

