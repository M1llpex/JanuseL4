/*
 * platforms/plat/shiba/src/plat_entry.S
 *
 * Copyright 2025, Millpex
 *
 * Initial entry point for the seL4 kernel on the shiba platform.
 */

#include <kernel/arch/asm_generic.S>
#include <kernel/platform_consts.S>

.global _start
.global plat_cpu_init_early

.text

/*
 * _start: Primary entry point for the kernel.
 * The bootloader jumps here with the CPU in EL2.
 */
_start:
    /* Only the primary core (core 0) performs the main initialization. */
    mrs     x0, mpidr_el1
    and     x0, x0, #MPIDR_CPU_MASK
    cbnz    x0, hang_secondary_cores

    /* Switch to the kernel stack. */
    ldr     x0, =kernel_stack_end
    mov     sp, x0

    /* Clear the BSS section. */
    ldr     x0, =__bss_start__
    ldr     x1, =__bss_end__
clear_bss_loop:
    cmp     x0, x1
    b.ge    bss_cleared
    str     xzr, [x0], #8
    b       clear_bss_loop
bss_cleared:

    /* Perform early platform initialization (e.g., UART). */
    bl      plat_serial_init

    /* Jump to the main kernel initialization. */
    b       kernel_main

/*
 * Secondary cores will spin here until the kernel wakes them.
 */
hang_secondary_cores:
    wfe
    b       hang_secondary_cores

/*
 * plat_cpu_init_early: Called by the kernel on each core
 * before it is fully operational.
 */
plat_cpu_init_early:
    /* Initialize the GIC for the current core. */
    bl      plat_interrupt_controller_init
    ret
