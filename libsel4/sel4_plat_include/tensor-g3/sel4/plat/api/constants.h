/*
 * Copyright 2023, Your Name
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#pragma once

/* The number of GIC SPI interrupts. */
#define seL4_NumSpis (480)

/* The number of GIC PPI interrupts. */
#define seL4_NumPpis (16)

/* The total number of interrupts */
#define seL4_NumIRQ (seL4_NumSpis + seL4_NumPpis + 32)
