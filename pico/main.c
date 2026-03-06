#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pico/stdlib.h"

#include "pico/multicore.h"
#include "pico/util/queue.h"

#include "cartridge.h"

//*************************************************************************************************

// global vars
queue_t msg_queue;
volatile bool start = false;

//*************************************************************************************************

uint16_t getHexFromUser()
{
    char buf[6];
    char* endptr;
    memset(buf, 0, sizeof(buf));

    // ex: user will type 00ff then hit enter
    fgets(buf, sizeof(buf), stdin);
    uint16_t number = strtol(buf, &endptr, 16);
    
    return number;
}

//*************************************************************************************************

void core1_entry()
{
    while (true)
    {
        if (!start)
        {
            // we have not received the start signal yet, keep waiting
            sleep_ms(1);
            continue;
        }

        // we received the start signal, reset it then grab the data from the cartridge
        start = false;

        const uint32_t MAX_ADDRESS = 0x7FFF; // 0x7FFF
        for (uint32_t addr = 0; addr <= MAX_ADDRESS; addr++)
        {
            set_address_bus(addr);
            sleep_us(1);
            set_read_signal(false);
            sleep_us(1);
            uint8_t data = get_data_bus();
            set_read_signal(true);

            // send the byte to core0
            queue_add_blocking(&msg_queue, &data);
            //sleep_us(1); // TODO: is this delay needed?
        }
    }
}

//*************************************************************************************************

int main()
{
    stdio_init_all();

    queue_init(&msg_queue, sizeof(uint8_t), 1000);
    multicore_launch_core1(core1_entry);

    // init the status LED
    //gpio_init(PICO_DEFAULT_LED_PIN);
    //gpio_set_dir(PICO_DEFAULT_LED_PIN, GPIO_OUT);

    // initialize the I/O expanders and set the signals to their default of high/low
    bool success = init_cartridge();

    while (true)
    {
        uint8_t data;
        bool newData = queue_try_remove(&msg_queue, &data);
        if (newData)
        {
            // if core1 gave us data through the queue then send it to the host PC
            fwrite(&data, 1, 1, stdout);
            fflush(stdout);
        }

        int c = getchar_timeout_us(0);
        if (PICO_ERROR_TIMEOUT == c)
        {
            // no cmd received from host PC, back to beginning of loop
            continue;
        }

        if ('z' == c)
        {
            stdio_set_translate_crlf(&stdio_usb, true);
            printf("success = %d\n", success == true ? 1 : 0);
        }
        else if ('a' == c)
        {
            stdio_set_translate_crlf(&stdio_usb, true);
            uint16_t addr = getHexFromUser();
            printf("setting to addr 0x%x\n", addr);
            set_address_bus(addr);
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
        else if ('l' == c)
        {
            set_read_signal(false);
        }
        else if ('h' == c)
        {
            set_read_signal(true);
        }
        else if ('g' == c)
        {
            // the SDK will translate LF to CRLF by default, so turn that off because we are sending binary data
            stdio_set_translate_crlf(&stdio_usb, false);
            start = true;
        }

        // toggle the status LED
        //gpio_put(PICO_DEFAULT_LED_PIN, !gpio_get(PICO_DEFAULT_LED_PIN));
        //sleep_ms(1000);
    }
}
