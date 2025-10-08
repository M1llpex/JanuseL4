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
