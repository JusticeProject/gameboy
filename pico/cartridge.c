#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/i2c.h"

#include "cartridge.h"

//*************************************************************************************************

// i2c config
#define I2C_PORT i2c1
// SDA is GPIO 14, physical pin 19
// SCL is GPIO 15, physical pin 20
#define I2C_SDA_GPIO_PIN 14
#define I2C_SCL_GPIO_PIN 15

// i2c addresses
#define I2C_ADDR_FOR_CART_ADDR 0x20
#define I2C_ADDR_FOR_CART_DATA 0x21

// register addresses, using the default BANK = 0 and Sequential Operation = enabled
#define REG_ADDR_IOCON 0x0A
#define REG_ADDR_IODIRA 0x00
#define REG_ADDR_IODIRB 0x01
#define REG_ADDR_GPIOA 0x12
#define REG_ADDR_GPIOB 0x13

//*************************************************************************************************

void init_cartridge()
{
    // i2c Initialisation. Using it at 100Khz.
    i2c_init(I2C_PORT, 100*1000);
    gpio_set_function(I2C_SDA_GPIO_PIN, GPIO_FUNC_I2C);
    gpio_set_function(I2C_SCL_GPIO_PIN, GPIO_FUNC_I2C);
    // TODO: the logic level converter board also has pull-ups, so maybe I don't need to enable them here
    gpio_pull_up(I2C_SDA_GPIO_PIN);
    gpio_pull_up(I2C_SCL_GPIO_PIN);
}

//*************************************************************************************************

void read_registers()
{
    uint8_t reg_addr = 0;
    uint8_t buffer[2];

    // write the register address first, keep control of the bus, then read the value
    reg_addr = REG_ADDR_IOCON;
    int bytes_written = i2c_write_blocking(I2C_PORT, I2C_ADDR_FOR_CART_ADDR, &reg_addr, 1, true); // true to keep master control of bus
    int bytes_read = i2c_read_blocking(I2C_PORT, I2C_ADDR_FOR_CART_ADDR, buffer, 1, false);

    printf("for reg_addr = 0x%x: bytes_written = %d, bytes_read = %d, buffer[0] = 0x%x\n", 
        reg_addr, bytes_written, bytes_read, buffer[0]);
    
    reg_addr = REG_ADDR_IODIRA;
    bytes_written = i2c_write_blocking(I2C_PORT, I2C_ADDR_FOR_CART_ADDR, &reg_addr, 1, true); // true to keep master control of bus
    bytes_read = i2c_read_blocking(I2C_PORT, I2C_ADDR_FOR_CART_ADDR, buffer, 2, false);

    printf("for reg_addr = 0x%x: bytes_written = %d, bytes_read = %d, buffer[0] = 0x%x, buffer[1] = 0x%x\n", 
        reg_addr, bytes_written, bytes_read, buffer[0], buffer[1]);

    reg_addr = REG_ADDR_GPIOA;
    bytes_written = i2c_write_blocking(I2C_PORT, I2C_ADDR_FOR_CART_ADDR, &reg_addr, 1, true); // true to keep master control of bus
    bytes_read = i2c_read_blocking(I2C_PORT, I2C_ADDR_FOR_CART_ADDR, buffer, 2, false);

    printf("for reg_addr = 0x%x: bytes_written = %d, bytes_read = %d, buffer[0] = 0x%x, buffer[1] = 0x%x\n", 
        reg_addr, bytes_written, bytes_read, buffer[0], buffer[1]);
}

//*************************************************************************************************

void write_registers()
{
    // TODO: when rebooting the Pico, the GPIO expander does not reboot. How should I handle this?
    // We want the GPIO to default to high impedance.

    // First byte is address, the following bytes are data.
    // Change all the GPIO directions to be outputs.
    uint8_t buffer[] = {REG_ADDR_IODIRA, 0x00, 0x00};
    int bytes_written = i2c_write_blocking(I2C_PORT, I2C_ADDR_FOR_CART_ADDR, buffer, 3, false); 
    printf("for reg_addr = 0x%x: bytes_written = %d\n", REG_ADDR_IODIRA, bytes_written);

    // Set all GPIO high.
    buffer[0] = REG_ADDR_GPIOA;
    buffer[1] = 0xFF;
    buffer[2] = 0xFF;
    bytes_written = i2c_write_blocking(I2C_PORT, I2C_ADDR_FOR_CART_ADDR, buffer, 3, false); 
    printf("for reg_addr = 0x%x: bytes_written = %d\n", REG_ADDR_IODIRA, bytes_written);
}

//*************************************************************************************************

bool reserved_addr(uint8_t addr)
{
    return (addr & 0x78) == 0 || (addr & 0x78) == 0x78;
}

//*************************************************************************************************

void scan_bus()
{
    printf("\nI2C Bus Scan\n");
    printf("@ = device found\n");
    printf(". = no device found\n");
    printf("  = not scanned (reserved address)\n\n");
    printf("   0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F\n");

    for (int addr = 0; addr < (1 << 7); ++addr)
    {
        if (addr % 16 == 0) {
            printf("%02x ", addr);
        }

        // Perform a 1-byte dummy read at the current address using i2c_read_blocking().
        // If a peripheral acknowledges this address, the function returns the number of bytes
        // transferred.
        // We try to read 1 byte so the device will transfer 1 byte to us if it supports that operation.
        // If the device is there but doesn't support reading then the function call returns 0 bytes read??
        // Or does it return 1 byte read with the data being 0x00??
        // If the address is ignored (no device on the bus with that address), the function returns -1. 

        // Skip over any reserved addresses.
        if (reserved_addr(addr))
        {
            printf(" ");
        }
        else
        {
            uint8_t rxdata;
            int ret = i2c_read_blocking(I2C_PORT, addr, &rxdata, 1, false);
            printf(ret < 0 ? "." : "@");
        }

        printf(addr % 16 == 15 ? "\n" : "  ");
    }
    printf("Done.\n");
}
