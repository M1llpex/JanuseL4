#!/bin/bash
# Fix script for seL4 Shiba platform build issues
# Run this from your seL4 directory

echo "Fixing seL4 Shiba platform configuration..."

# 1. Fix the platform_gen.h.in template
cat > src/arch/arm/platform_gen.h.in << 'EOF'
/*
 * Copyright 2020, Data61, CSIRO (ABN 41 687 119 230)
 *
 * SPDX-License-Identifier: GPL-2.0-only
 */

#pragma once

#include <config.h>

/* Timer interrupt will be defined by the device tree or config */
#ifndef KERNEL_TIMER_IRQ
#define KERNEL_TIMER_IRQ @CONFIGURE_KERNEL_TIMER_IRQ@
#endif

#define TIMER_CLOCK_HZ ULL_CONST(@CONFIGURE_TIMER_FREQUENCY@)
#define CLK_MAGIC @CONFIGURE_CLK_MAGIC@
#define CLK_SHIFT @CONFIGURE_CLK_SHIFT@
#define TIMER_PRECISION @CONFIGURE_TIMER_PRECISION@
#define TIMER_OVERHEAD_TICKS @CONFIGURE_TIMER_OVERHEAD_TICKS@

enum IRQConstants {
    maxIRQ                      = @CONFIGURE_MAX_IRQ@
};

#define IRQ_CNODE_SLOT_BITS (@CONFIGURE_IRQ_SLOT_BITS@)

#include <@CONFIGURE_INTERRUPT_CONTROLLER@>
#include <@CONFIGURE_TIMER@>

#cmakedefine CONFIGURE_SMMU <@CONFIGURE_SMMU@>
#if (defined(CONFIGURE_SMMU) && defined(CONFIG_TK1_SMMU))
#include CONFIGURE_SMMU
#endif

#cmakedefine CONFIGURE_SMMU <@CONFIGURE_SMMU@>
#if (defined(CONFIGURE_SMMU) && defined(CONFIG_ARM_SMMU))
#include CONFIGURE_SMMU

#define SMMU_MAX_SID  @CONFIGURE_MAX_SID@
#define SMMU_MAX_CB  @CONFIGURE_MAX_CB@

#endif

#ifdef CONFIG_KERNEL_MCS
static inline CONST time_t getKernelWcetUs(void)
{
    return @CONFIGURE_KERNEL_WCET@;
}
#endif
EOF

# 2. Update the Shiba config.cmake
cat > src/plat/shiba/config.cmake << 'EOF'
#
# Copyright 2025, Millpex
#
# SPDX-License-Identifier: BSD-2-Clause
#

# Declare the platform and the architecture it supports
declare_platform(shiba KernelPlatShiba PLAT_SHIBA KernelSel4ArchAarch64)

# This block is only processed when 'shiba' is the selected platform
if(KernelPlatShiba)
    
    list(APPEND KernelDTSList "src/plat/shiba/pixel8.dts")

    # 1. Declare the seL4 architecture for the kernel
    declare_seL4_arch(aarch64)
    set(KernelArmGicV3 ON)
    set(KernelArmCortexA72 ON)
    set(KernelArchArmV8a ON)
    config_set(KernelARMPlatform ARM_PLAT shiba)
    config_set(KernelArmMach MACH "google")
    
    # Calculate CLK_MAGIC and CLK_SHIFT for 100MHz timer
    # Using: python3 tools/reciprocal.py --divisor 100000000
    declare_default_headers(
        TIMER_FREQUENCY 100000000
        MAX_IRQ 512
        NUM_PPI 32
        KERNEL_TIMER_IRQ 27  # ARM Generic Timer Virtual Timer IRQ (PPI 11 + 16)
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
    CFILES src/arch/arm/machine/gic_v3.c src/arch/arm/machine/l2c_nop.c
)
EOF

# 3. Remove the duplicate initTimer function from hardware.c
cat > src/plat/shiba/machine/hardware.c << 'EOF'
/*
 * Copyright 2025, Millpex
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#include <config.h>
#include <types.h>
#include <machine/io.h>
#include <kernel/vspace.h>
#include <arch/machine.h>
#include <arch/kernel/vspace.h>
#include <plat/machine.h>
#include <linker.h>
#include <plat/machine/devices_gen.h>
#include <plat/machine/hardware.h>

/* Available physical memory regions on the Shiba platform.
 * These will be refined later. */
static const p_region_t BOOT_RODATA avail_p_regs[] = {
    /* 2 GiB starting at 0x80000000 */
    { .start = 0x80000000, .end = 0x100000000 }
};

BOOT_CODE size_t get_num_avail_p_regs(void)
{
    return sizeof(avail_p_regs) / sizeof(p_region_t);
}

BOOT_CODE p_region_t get_avail_p_reg(word_t i)
{
    return avail_p_regs[i];
}

BOOT_CODE void map_kernel_devices(void)
{
    /* Map GIC Distributor */
    map_kernel_frame(GIC_DIST_PADDR, GIC_DIST_PPTR, VMKernelOnly, vm_attributes_new(true, false, false));
    
    /* Map GIC Redistributor - map multiple frames as redistributor can be large */
    for (int i = 0; i < 16; i++) {
        map_kernel_frame(GIC_REDIST_PADDR + (i * BIT(PAGE_BITS)), 
                        GIC_REDIST_PPTR + (i * BIT(PAGE_BITS)),
                        VMKernelOnly, 
                        vm_attributes_new(true, false, false));
    }
}

/* Timer is initialized by the ARM generic timer driver */
/* GIC is initialized by the GICv3 driver */
EOF

# 4. Update machine.h to handle interrupt macros correctly
cat > include/plat/shiba/plat/machine.h << 'EOF'
/*
 * Copyright 2025, Millpex
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#pragma once

#include <config.h>
#include <autoconf.h>
#include <sel4/macros.h>
#include <sel4/plat/api/constants.h>

/* GIC-related definitions */
#define GIC_DIST_PADDR   0x10400000
#define GIC_DIST_PPTR    0xffff000040000000
#define GIC_REDIST_PADDR 0x10440000
#define GIC_REDIST_PPTR  0xffff000040040000

/* Interrupt vectors for the GIC */
#define SGI_IRQ_OFFSET  0
#define PPI_IRQ_OFFSET  16
#define SPI_IRQ_OFFSET  32

/* IRQ definitions for non-SMP builds */
#ifndef ENABLE_SMP_SUPPORT
#define CORE_IRQ_TO_IRQT(target, irq) (irq)
#define IRQT_TO_IRQ(irqt) (irqt)
#define IRQT_TO_CORE(irqt) 0
#define IRQT_TO_IDX(irqt) (irqt)
#define IRQ_IS_PPI(irq) ((irq) >= PPI_IRQ_OFFSET && (irq) < SPI_IRQ_OFFSET)
#endif

/* Include generated headers */
#include <gen_headers/plat/machine/devices_gen.h>
#include <gen_config/plat/platform_gen.h>
#include <machine/interrupt.h>
EOF

# 5. Create a simple devices_gen.h if it doesn't exist properly
mkdir -p build/gen_headers/plat/machine
cat > build/gen_headers/plat/machine/devices_gen.h << 'EOF'
/*
 * Auto-generated by seL4 build system
 */
#pragma once

/* Device memory regions - placeholder values */
#define RAM_BASE  0x80000000
#define RAM_END   0x100000000
EOF

echo "Fixes applied. Now clean and rebuild:"
echo ""
echo "cd ~/seL4/build"
echo "rm -rf *"
echo "cmake -DCROSS_COMPILER_PREFIX=aarch64-linux-gnu- -DCMAKE_TOOLCHAIN_FILE=../gcc.cmake -DPLATFORM=shiba -DKernelPlatform=shiba .."
echo "ninja"
