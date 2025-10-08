/*
 * Copyright 2023, Your Name
 * SPDX-License-Identifier: BSD-2-Clause
 */

#include <autoconf.h>
#include <sel4/macros.h>
#include <sel4/plat/api/constants.h>
#include <gen_config/plat/platform_gen.h>
#include <plat/gic.h>
#include <utils/util.h>

/*
 * These global variables are what the linker is looking for.
 * They will be populated with the VIRTUAL addresses after the MMU is on.
 */
void *gic_dist;
void *gic_rdist_sgi_ppi_map;
volatile irq_t active_irq = 0;

// Reads the core's affinity register MPIDR_EL1
static inline uint64_t read_mpidr(void) {
    uint64_t mpidr;
    asm volatile("mrs %0, mpidr_el1" : "=r" (mpidr));
    return mpidr;
}

// Main GIC initialization, called on the primary core
void initIRQController(void) {
    /*
     * Here you would map the physical addresses (GIC_DIST_PADDR) into
     * virtual addresses and store them in the global 'gic_dist' pointer.
     * For now, we'll assume a direct mapping for simplicity to get it to link.
     */
    gic_dist = (void*)GIC_DIST_PADDR;

    // Enable affinity routing and Group 1 interrupts in the distributor
    uint32_t ctlr_val = ZF_LOGF_IO_RD32((uintptr_t)gic_dist + GICD_CTLR);
    ctlr_val |= GICD_CTLR_ARE_S | 1;
    ZF_LOGF_IO_WR32((uintptr_t)gic_dist + GICD_CTLR, ctlr_val);

    // Call the per-core init function for the primary core
    cpu_initLocalIRQController();
}

// Per-core GIC initialization
void cpu_initLocalIRQController(void) {
    uint64_t cpu_id = read_mpidr() & 0xFF;

    /*
     * Map the redistributor physical address. This is a simplified example.
     */
    gic_rdist_sgi_ppi_map = (void*)(GIC_RDIST_PADDR + (cpu_id * GICR_STRIDE));

    // Wake up this core's GIC Redistributor
    uintptr_t gicr_base = (uintptr_t)gic_rdist_sgi_ppi_map;
    uint32_t waker_val = ZF_LOGF_IO_RD32(gicr_base + GICR_WAKER);
    ZF_LOGF_IO_WR32(gicr_base + GICR_WAKER, waker_val & ~GICR_WAKER_PROCESSORSLEEP);
    while (ZF_LOGF_IO_RD32(gicr_base + GICR_WAKER) & GICR_WAKER_CHILDRENASLEEP);

    // Configure the CPU Interface via system registers for GICv3
    uint64_t sre_val;
    asm volatile("mrs %0, icc_sre_el2" : "=r" (sre_val));
    sre_val |= 1;
    asm volatile("msr icc_sre_el2, %0" :: "r" (sre_val));
    asm volatile("msr icc_igrpen1_el1, %0" :: "r" (1UL));
    asm volatile("msr icc_pmr_el1, %0" :: "r" (0xFFUL));
}

// Stub for setting IRQ trigger type (not implemented yet)
void setIRQTrigger(irq_t irq, int trigger) {}
