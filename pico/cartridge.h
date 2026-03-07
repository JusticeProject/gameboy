#include <stdint.h>
#include <stdbool.h>

bool init_cartridge();
uint8_t set_addr_read_data(uint16_t addr);

bool set_address_bus(uint16_t addr);
void set_read_signal(bool level);
uint8_t get_data_bus();

void test_read_registers();

void scan_bus();
