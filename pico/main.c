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

void read_bank(uint8_t cartridgeType, uint8_t bank)
{
    // TODO: need to handle other cartridge types with memory bank controllers, need to load the higher
    // numbered banks first before reading it. Even if it's bank 1 we should load it first because the 
    // previous attempt to read the cartridge may have left it at bank 7 for example.

    uint16_t START_ADDRESS = (bank == 0) ? 0x0000 : 0x4000;
    uint16_t MAX_ADDRESS = (bank == 0) ? 0x3FFF : 0x7FFF;
    for (uint16_t addr = START_ADDRESS; addr <= MAX_ADDRESS; addr++)
    {
        uint8_t data = set_addr_read_data(addr);

        // send the byte to core0
        queue_add_blocking(&msg_queue, &data);
    }
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

        // first figure out what type of cartridge and how many banks there are
        const uint16_t HEADER_CARTRIDGE_TYPE_ADDR = 0x0147;
        const uint16_t HEADER_CARTRIDGE_ROM_SIZE_ADDR = 0x0148;
        uint8_t cartridgeType = set_addr_read_data(HEADER_CARTRIDGE_TYPE_ADDR);
        uint8_t romSizeCode = set_addr_read_data(HEADER_CARTRIDGE_ROM_SIZE_ADDR);

        // Calculate the total number of banks.
        // If code = 0 then numBanks = 2
        // If code = 1 then numBanks = 4
        // If code = 2 then numBanks = 8, etc.
        uint8_t numBanks = (1 << (romSizeCode + 1));

        // read all the banks
        for (uint8_t bank = 0; bank < numBanks; bank++)
        {
            read_bank(cartridgeType, bank);
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
