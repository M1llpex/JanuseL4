/*
 * Copyright 2025, Millpex
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#pragma once

#define TIMER_CLOCK_HZ 26000000ULL
#define KERNEL_TIMER_IRQ 30

#include <config.h>
#include <types.h>
#include <plat/machine/interrupt.h>

/* GIC Physical and Virtual addresses */
#define GIC_DIST_PADDR  0x17a00000
#define GIC_RDIST_PADDR 0x17a40000

#define GICD_PPTR   (KDEV_BASE)
#define GICR_PPTR   (KDEV_BASE + 0x100000)
