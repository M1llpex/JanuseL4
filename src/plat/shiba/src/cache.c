#include <plat/hardware.h>
#include <stdint.h>
#include <util.h>

/* ARMv8-A cache maintenance instructions */
#define DC_CVAU(addr) asm volatile("dc cvau, %0" :: "r"(addr))
#define DC_CIVAC(addr) asm volatile("dc civac, %0" :: "r"(addr))
#define DC_IVAC(addr) asm volatile("dc ivac, %0" :: "r"(addr))

#define L1_CACHE_LINE_SIZE_LOG2 6
#define L1_CACHE_LINE_SIZE (1 << L1_CACHE_LINE_SIZE_LOG2)

void plat_cleanL2Range(size_t start, size_t end)
{
    size_t i;
    for (i = round_down(start, L1_CACHE_LINE_SIZE); i < end; i += L1_CACHE_LINE_SIZE) {
        DC_CVAU(i);
    }
    asm volatile("dsb sy");
}

void plat_invalidateL2Range(size_t start, size_t end)
{
    size_t i;
    for (i = round_down(start, L1_CACHE_LINE_SIZE); i < end; i += L1_CACHE_LINE_SIZE) {
        DC_IVAC(i);
    }
    asm volatile("dsb sy");
    asm volatile("isb");
}

void plat_cleanInvalidateL2Range(size_t start, size_t end)
{
    size_t i;
    for (i = round_down(start, L1_CACHE_LINE_SIZE); i < end; i += L1_CACHE_LINE_SIZE) {
        DC_CIVAC(i);
    }
    asm volatile("dsb sy");
    asm volatile("isb");
}

void plat_cleanInvalidateL2Cache(void)
{
    /* This function would be more complex and requires knowledge of the L2 cache size */
    /* and set/way manipulation instructions, or a direct full flush instruction if available. */
    /* A simple, but less efficient, approach would be to iterate over the entire memory range. */
}
