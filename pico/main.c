#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/spi.h"

// SPI Defines
// We are going to use SPI 0, and allocate it to the following GPIO pins
#define SPI_PORT spi0
#define PIN_SCK  2
#define PIN_MOSI 3


int main()
{
    stdio_init_all();

    // init the status LED
    gpio_init(PICO_DEFAULT_LED_PIN);
    gpio_set_dir(PICO_DEFAULT_LED_PIN, GPIO_OUT);

    // SPI initialisation. This example will use SPI at 5MHz.
    uint baudrate = spi_init(SPI_PORT, 5*1000*1000);
    spi_set_format(SPI_PORT, 8, 0, 0, SPI_MSB_FIRST);
    gpio_set_function(PIN_SCK,  GPIO_FUNC_SPI);
    gpio_set_function(PIN_MOSI, GPIO_FUNC_SPI);

    while (true)
    {
        // toggle the status LED
        gpio_put(PICO_DEFAULT_LED_PIN, !gpio_get(PICO_DEFAULT_LED_PIN));

        printf("Actual SPI baudrate = %d\n", baudrate);
        sleep_ms(1000);

        uint8_t data = 0xFF;
        spi_write_blocking(SPI_PORT, &data, 1);
        sleep_ms(1000);

        data = 0x0F;
        spi_write_blocking(SPI_PORT, &data, 1);
        sleep_ms(1000);

        data = 0xF0;
        spi_write_blocking(SPI_PORT, &data, 1);
        sleep_ms(1000);
    }
}
