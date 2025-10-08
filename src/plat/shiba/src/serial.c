#include <sel4/simple_types.h>
#include <plat/serial.h>
#include <utils/util.h>

// Simple MMIO read/write helpers for the UART registers
static inline void mmio_write(uintptr_t addr, uint32_t val) {
    *(volatile uint32_t *)addr = val;
}
static inline uint32_t mmio_read(uintptr_t addr) {
    return *(volatile uint32_t *)addr;
}

// Function to send a single character to the serial console
void plat_serial_putchar(int c) {
    // Wait until the transmitter buffer is empty
    while (!(mmio_read(SHIBA_UART_BASE + S3C2410_UTRSTAT) & S3C2410_UTRSTAT_TXE));

    // Write the character to the transmit holding register
    mmio_write(SHIBA_UART_BASE + S3C2410_UTXH, (uint32_t)c);

    // Also send carriage return with every newline
    if (c == '\n') {
        plat_serial_putchar('\r');
    }
}

// Main serial initialization function
void plat_serial_init(void) {
    // Set line control for 8 data bits, no parity, and 1 stop bit (8N1)
    mmio_write(SHIBA_UART_BASE + S3C2410_ULCON, S3C2410_LCON_CS8);

    // Set control for polling mode
    mmio_write(SHIBA_UART_BASE + S3C2410_UCON, S3C2410_UCON_TXIRQMODE | S3C2410_UCON_RXIRQMODE);

    // Enable and reset FIFOs (First-In, First-Out buffers)
    mmio_write(SHIBA_UART_BASE + S3C2410_UFCON, S3C2410_UFCON_FIFOMODE | S3C2410_UFCON_RESETTX | S3C2410_UFCON_RESETRX);

    // Set the baud rate to 115200 by writing a divisor value
    mmio_write(SHIBA_UART_BASE + S3C2410_UBRDIV, 107);
    
    // Ignore the fractional part for simplicity
    mmio_write(SHIBA_UART_BASE + S3C2443_DIVSLOT, 0x0);

    // Print a newline to indicate the console is ready
    plat_serial_putchar('\n');
}
