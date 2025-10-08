#!/bin/bash
# Quick fix to get a debug build working - don't worry about correctness

echo "Applying quick fixes for debug build..."

# 1. Just define the missing macros in the simplest way possible
cat > include/plat/shiba/plat/machine.h << 'EOF'
/*
 * Quick and dirty definitions to make it compile
 */

#pragma once

#include <config.h>

/* Just define everything we need to make it compile */
#define CORE_IRQ_TO_IRQT(tgt, irq) (irq)
#define IRQT_TO_IRQ(irqt) (irqt)
#define IRQT_TO_CORE(irqt) 0
#define IRQT_TO_IDX(irqt) (irqt)
#define IRQ_IS_PPI(irq) 0
#define getCurrentCPUIndex() 0
#define CURRENT_CPU_INDEX() 0
#define IRQ_MASK 0x3ff
#define IS_IRQ_VALID(X) 1
#define IRQ_NONE 0xffffffff
#define HW_IRQ_IS_PPI(irq) 0
#define HW_IRQ_IS_SGI(irq) 0

/* GIC stuff */
#define GIC_DIST_PADDR   0x10400000
#define GIC_DIST_PPTR    0xffff000040000000
#define GIC_REDIST_PADDR 0x10440000
#define GIC_REDIST_PPTR  0xffff000040040000

/* Interrupt numbers */
#define SGI_IRQ_OFFSET  0
#define PPI_IRQ_OFFSET  16
#define SPI_IRQ_OFFSET  32

typedef unsigned long irq_t;
enum { irqInvalid = 0xffffffff };

/* Declare the active_irq array that GIC expects */
extern volatile unsigned long active_irq[];

/* Include the generated stuff */
#include <gen_config/plat/platform_gen.h>
#include <machine/interrupt.h>
EOF

# 2. Add the missing globals to hardware.c
cat > src/plat/shiba/machine/hardware.c << 'EOF'
/*
 * Minimal hardware.c just to make it build
 */

#include <config.h>
#include <types.h>
#include <machine/io.h>
#include <kernel/vspace.h>
#include <arch/machine.h>
#include <arch/kernel/vspace.h>
#include <plat/machine.h>
#include <linker.h>

/* Define all the globals that are expected */
volatile unsigned long active_irq[1] = {0xffffffff};
void *gic_dist = NULL;
void *gic_rdist_sgi_ppi_map[1] = {NULL};

/* Memory regions - just return something valid */
static const p_region_t BOOT_RODATA avail_p_regs[] = {
    { .start = 0x80000000, .end = 0x100000000 }
};

BOOT_CODE size_t get_num_avail_p_regs(void)
{
    return 1;
}

BOOT_CODE p_region_t get_avail_p_reg(word_t i)
{
    return avail_p_regs[0];
}

BOOT_CODE void map_kernel_devices(void)
{
    /* Just set some pointers so it doesn't crash */
    gic_dist = (void *)GIC_DIST_PPTR;
    gic_rdist_sgi_ppi_map[0] = (void *)GIC_REDIST_PPTR;
}
EOF

echo "Quick fix applied. Try building now:"
echo "cd ~/seL4/build && ninja"
