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

    init_cartridge();

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
            printf("hello\n");
        }
        else if ('r' == c)
        {
            stdio_set_translate_crlf(&stdio_usb, true);
            read_registers();
        }
        else if ('w' == c)
        {
            stdio_set_translate_crlf(&stdio_usb, true);
            write_registers();
        }
        else if ('s' == c)
        {
            stdio_set_translate_crlf(&stdio_usb, true);
            scan_bus();
        }
        else if ('g' == c)
        {
            // the SDK will translate LF to CRLF by default, so turn that off because we are sending binary data
            stdio_set_translate_crlf(&stdio_usb, false);
            printf("test\n");
        }

        // toggle the status LED
        //gpio_put(PICO_DEFAULT_LED_PIN, !gpio_get(PICO_DEFAULT_LED_PIN));
        //sleep_ms(1000);
    }
}
