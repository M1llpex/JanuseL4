/* platforms/plat/shiba/include/plat/serial.h */

#pragma once

#define SHIBA_UART_BASE 0x10870000

/* Register Offsets */
#define S3C2410_ULCON      0x00  // Line Control
#define S3C2410_UCON       0x04  // Control
#define S3C2410_UFCON      0x08  // FIFO Control
#define S3C2410_UTRSTAT    0x10  // Tx/Rx Status
#define S3C2410_UFSTAT     0x18  // FIFO Status
#define S3C2410_UTXH       0x20  // Transmit Holding Register
#define S3C2410_URXH       0x24  // Receive Buffer Register
#define S3C2410_UBRDIV     0x28  // Baud Rate Divisor
#define S3C2443_DIVSLOT    0x2C  // Fractional Baud Rate (UFRACVAL)

/* UTRSTAT Bits */
#define S3C2410_UTRSTAT_TXE (1 << 2) // Transmitter buffer empty

/* ULCON Bits (for 8N1 configuration) */
#define S3C2410_LCON_CS8   0x3       // 8 data bits, no parity, 1 stop bit

/* UCON Bits */
#define S3C2410_UCON_TXIRQMODE (1 << 2) // Select TX Interrupt/Polling
#define S3C2410_UCON_RXIRQMODE (1 << 0) // Select RX Interrupt/Polling

/* UFCON Bits */
#define S3C2410_UFCON_FIFOMODE (1 << 0) // Enable FIFOs
#define S3C2410_UFCON_RESETTX  (1 << 2) // Reset TX FIFO
#define S3C2410_UFCON_RESETRX  (1 << 1) // Reset RX FIFO
