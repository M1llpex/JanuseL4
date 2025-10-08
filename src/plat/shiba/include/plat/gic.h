/* platforms/plat/shiba/include/plat/gic.h */

#pragma once

/* GIC Physical Base Addresses */
#define GIC_DIST 0x10400000  // GIC Distributor
#define GIC_RDIST 0x10440000  // GIC Re-distributors
#define GICR_STRIDE 0x20000
/* GICR stride for each core, 128KB for GICv3 */
#define GICR_STRIDE 0x20000

/* Key GICD Register Offsets */
#define GICD_CTLR     0x0000 // Distributor Control Register
#define GICD_IGROUPR 0x0080 // Interrupt Group Registers
#define GICD_ISENABLER 0x0100 // Set-Enable Registers

/* Key GICR Register Offsets */
#define GICR_WAKER    0x0014 // Wake Register

/* GICD_CTLR Bits */
#define GICD_CTLR_ARE_S (1U << 4) // Affinity Routing Enable (Secure)

/* GICR_WAKER Bits */
#define GICR_WAKER_PROCESSORSLEEP (1U << 1)
#define GICR_WAKER_CHILDRENASLEEP (1U << 2)
