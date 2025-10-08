/*
 * Copyright 2025, Millpex
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#include <config.h>
#include <stdint.h>
#include <util.h>
#include <machine.h>
#include <plat/machine.h>
#include <armv/machine.h>
#include <arch/machine/gic_v3.h>

/* Timer initialization - uses ARM Generic Timer */
void initTimer(void)
{
    /* ARM Generic Timer is initialized by hardware/firmware */
    /* Nothing specific needed for your platform */
}
