#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/i2c.h"

#include "cartridge.h"

//*************************************************************************************************

// GPIO for driving the optocoupler. When set high it turns the optocoupler on and connects the 
// (active low) RESET pin on the I/O expanders to 5V, thus enabling them. When low the optocoupler is off
// and the (active low) RESET pin is pulled to 0V through a 2k ohm resistor, thus disabling the I/O expanders.
// GPIO 13 which is physical pin 17. Uses a 470 ohm current limiting resistor for the input diode.
#define OPTOCOUPLER_GPIO_PIN 13

// i2c config
#define I2C_PORT i2c1
// SDA is GPIO 14, physical pin 19
// SCL is GPIO 15, physical pin 20
#define I2C_SDA_GPIO_PIN 14
#define I2C_SCL_GPIO_PIN 15

//*************************************************************************************************

// i2c address for cart's address bus
#define I2C_ADDR_FOR_CART_ADDR 0x20

// register addresses use the default BANK = 0 and Sequential Operation = enabled
#define REG_IOCON 0x0A

// registers for the cart's address bus
#define REG_IODIRA_LOW_ADDR_BUS 0x00
#define REG_IODIRB_HIGH_ADDR_BUS 0x01
#define REG_GPIOA_LOW_ADDR_BUS 0x12
#define REG_GPIOB_HIGH_ADDR_BUS 0x13

//*************************************************************************************************

// i2c address for cart's control signals and data bus
#define I2C_ADDR_FOR_CART_DATA_CONTROL 0x21

// registers for the cart's control signals and data bus
#define REG_IODIRA_DATA_BUS 0x00
#define REG_IODIRB_CONTROL_SIGNALS 0x01
#define REG_GPIOA_DATA_BUS 0x12
#define REG_GPIOB_CONTROL_SIGNALS 0x13

//*************************************************************************************************

bool init_cartridge()
{
    // bring the I/O expanders out of reset, give them some time to stabilize
    gpio_init(OPTOCOUPLER_GPIO_PIN);
    gpio_set_dir(OPTOCOUPLER_GPIO_PIN, GPIO_OUT);
    gpio_set_drive_strength(OPTOCOUPLER_GPIO_PIN, GPIO_DRIVE_STRENGTH_8MA);
    gpio_put(OPTOCOUPLER_GPIO_PIN, false);
    sleep_ms(1);
    gpio_put(OPTOCOUPLER_GPIO_PIN, true);
    sleep_ms(1);

    // i2c Initialisation. Using it at 100Khz.
    i2c_init(I2C_PORT, 100*1000);
    gpio_set_function(I2C_SDA_GPIO_PIN, GPIO_FUNC_I2C);
    gpio_set_function(I2C_SCL_GPIO_PIN, GPIO_FUNC_I2C);
    // TODO: the logic level converter board also has pull-ups, so maybe I don't need to enable them here
    gpio_pull_up(I2C_SDA_GPIO_PIN);
    gpio_pull_up(I2C_SCL_GPIO_PIN);

    uint8_t buffer[3];

    // The reset initialized all GPIOs on I/O expanders to inputs.
    // Configure control signals (RD, WR, CS/MREQ) to outputs and set them high.
    buffer[0] = REG_IODIRB_CONTROL_SIGNALS;
    buffer[1] = 0xF8; // 0b1111 1000 bits 0,1,2 will be outputs, the rest are inputs
    int bytes_written = i2c_write_blocking(I2C_PORT, I2C_ADDR_FOR_CART_DATA_CONTROL, buffer, 2, false);
    if (bytes_written != 2)
    {
        return false;
    }
    buffer[0] = REG_GPIOB_CONTROL_SIGNALS;
    buffer[1] = 0x07; // 0b0000 0111
    bytes_written = i2c_write_blocking(I2C_PORT, I2C_ADDR_FOR_CART_DATA_CONTROL, buffer, 2, false);
    if (bytes_written != 2)
    {
        return false;
    }

    // Init address bus to outputs then set to addr 0. Since the chip is in sequential mode, we can write both 
    // registers while only specifying the first register address.
    buffer[0] = REG_IODIRA_LOW_ADDR_BUS;
    buffer[1] = 0x00; // all 16 bits will ...
    buffer[2] = 0x00; // ... be outputs
    bytes_written = i2c_write_blocking(I2C_PORT, I2C_ADDR_FOR_CART_ADDR, buffer, 3, false);
    if (bytes_written != 3)
    {
        return false;
    }
    buffer[0] = REG_GPIOA_LOW_ADDR_BUS;
    buffer[1] = 0x00; // cart's address bus will be 0x00 ...
    buffer[2] = 0x00; // ... and 0x00
    bytes_written = i2c_write_blocking(I2C_PORT, I2C_ADDR_FOR_CART_ADDR, buffer, 3, false);
    if (bytes_written != 3)
    {
        return false;
    }

    return true;
}

//*************************************************************************************************

void set_address(uint16_t addr)
{

}

//*************************************************************************************************

void set_read_signal(bool level)
{

}

//*************************************************************************************************

uint8_t get_data()
{

}

//*************************************************************************************************

void read_registers(uint8_t i2c_addr)
{
    uint8_t reg_addr = 0;
    uint8_t buffer[2];

    printf("reading i2c addr 0x%x\n", i2c_addr);

    // write the register address first, keep control of the bus, then read the value
    reg_addr = REG_IOCON;
    int bytes_written = i2c_write_blocking(I2C_PORT, i2c_addr, &reg_addr, 1, true); // true to keep master control of bus
    int bytes_read = i2c_read_blocking(I2C_PORT, i2c_addr, buffer, 1, false);

    printf("for reg_addr = 0x%x: bytes_written = %d, bytes_read = %d, buffer[0] = 0x%x\n", 
        reg_addr, bytes_written, bytes_read, buffer[0]);
    
    reg_addr = REG_IODIRA_LOW_ADDR_BUS;
    bytes_written = i2c_write_blocking(I2C_PORT, i2c_addr, &reg_addr, 1, true); // true to keep master control of bus
    bytes_read = i2c_read_blocking(I2C_PORT, i2c_addr, buffer, 2, false);

    printf("for reg_addr = 0x%x: bytes_written = %d, bytes_read = %d, buffer[0] = 0x%x, buffer[1] = 0x%x\n", 
        reg_addr, bytes_written, bytes_read, buffer[0], buffer[1]);

    reg_addr = REG_GPIOA_LOW_ADDR_BUS;
    bytes_written = i2c_write_blocking(I2C_PORT, i2c_addr, &reg_addr, 1, true); // true to keep master control of bus
    bytes_read = i2c_read_blocking(I2C_PORT, i2c_addr, buffer, 2, false);

    printf("for reg_addr = 0x%x: bytes_written = %d, bytes_read = %d, buffer[0] = 0x%x, buffer[1] = 0x%x\n", 
        reg_addr, bytes_written, bytes_read, buffer[0], buffer[1]);
}

//*************************************************************************************************

void write_registers(uint8_t i2c_addr)
{
    /*printf("writing i2c addr 0x%x\n", i2c_addr);

    // First byte is address, the following bytes are data.
    // Change all the GPIO directions to be outputs.
    uint8_t buffer[] = {REG_ADDR_IODIRA, 0x00, 0x00};
    int bytes_written = i2c_write_blocking(I2C_PORT, i2c_addr, buffer, 3, false); 
    printf("for reg_addr = 0x%x: bytes_written = %d\n", REG_ADDR_IODIRA, bytes_written);

    // Set all GPIO high.
    buffer[0] = REG_ADDR_GPIOA;
    buffer[1] = 0xFF;
    buffer[2] = 0xFF;
    bytes_written = i2c_write_blocking(I2C_PORT, i2c_addr, buffer, 3, false); 
    printf("for reg_addr = 0x%x: bytes_written = %d\n", REG_ADDR_IODIRA, bytes_written);*/
}

//*************************************************************************************************

void test_read_registers()
{
    read_registers(I2C_ADDR_FOR_CART_ADDR);
    read_registers(I2C_ADDR_FOR_CART_DATA_CONTROL);
}

//*************************************************************************************************

void test_write_registers()
{
    write_registers(I2C_ADDR_FOR_CART_ADDR);
    //write_registers(I2C_ADDR_FOR_CART_DATA);
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
    printf("     0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F\n");

    for (int addr = 0; addr < (1 << 7); ++addr)
    {
        if (addr % 16 == 0) {
            printf("%02x   ", addr);
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
