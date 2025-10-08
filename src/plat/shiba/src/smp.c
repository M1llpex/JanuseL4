#include <plat/gic.h>
#include <stdint.h>
#include <config.h>

#define GICD_BASE 0x17400000 /* Placeholder, find the actual address from documentation */
#define GICD_SGIR (GICD_BASE + 0xF00)

void plat_sendSGI(uint64_t sgi_number, uint64_t target_cpu) {
    /*
     * The GICD_SGIR register is used to send Software Generated Interrupts (SGIs).
     * The register format includes fields for the target list, the SGI number,
     * and the target mode (e.g., specific CPUs, all other CPUs, etc.).
     * The value for `target_cpu` will need to be converted to the GIC-specific
     * target list format.
     */
    uint32_t sgi_reg_value = (1 << (16 + target_cpu)) | (sgi_number & 0xF);
    writel(sgi_reg_value, GICD_SGIR);
}

bool plat_SGITargetValid(uint64_t target_cpu) {
    /*
     * This function should verify if the `target_cpu` is a valid CPU to send
     * an SGI to. This can be as simple as checking if the CPU ID is
     * within the number of cores supported by the Tensor SoC.
     */
    return (target_cpu < CONFIG_MAX_NUM_CPUS);
}
