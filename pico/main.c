#include <stdio.h>
#include "pico/stdlib.h"

#include "cartridge.h"

//*************************************************************************************************

int main()
{
    stdio_init_all();

    // init the status LED
    //gpio_init(PICO_DEFAULT_LED_PIN);
    //gpio_set_dir(PICO_DEFAULT_LED_PIN, GPIO_OUT);

    // initialize the I/O expanders and set the signals to their default of high/low
    bool success = init_cartridge();

    while (true)
    {
        int c = getchar_timeout_us(0);
        if (PICO_ERROR_TIMEOUT == c)
        {
            // no data received from host PC, back to beginning of loop
            continue;
        }

        if ('z' == c)
        {
            stdio_set_translate_crlf(&stdio_usb, true);
            printf("success = %d\n", success == true ? 1 : 0);
        }
        else if ('r' == c)
        {
            stdio_set_translate_crlf(&stdio_usb, true);
            test_read_registers();
        }
        else if ('w' == c)
        {
            stdio_set_translate_crlf(&stdio_usb, true);
            test_write_registers();
        }
        else if ('s' == c)
        {
            stdio_set_translate_crlf(&stdio_usb, true);
            scan_bus();
        }
        else if ('g' == c)
        {
            // the SDK will translate LF to CRLF by default, so turn that off because we are sending binary data
            // TODO uncomment this when sending binary data
            //stdio_set_translate_crlf(&stdio_usb, false);

            const uint32_t MAX_ADDRESS = 0x0001; // 0x7FFF
            for (uint32_t addr = 0; addr <= MAX_ADDRESS; addr++)
            {
                set_address(addr);
                sleep_us(1);
                set_read_signal(false);
                sleep_us(1);
                uint8_t data = get_data();
                set_read_signal(true);
                sleep_us(1); // TODO: is this delay needed?

                // TODO: switch to binary communication with host
                printf("addr 0x%x has data 0x%x\n", addr, data);
            }
        }

        // toggle the status LED
        //gpio_put(PICO_DEFAULT_LED_PIN, !gpio_get(PICO_DEFAULT_LED_PIN));
        //sleep_ms(1000);
    }
}
