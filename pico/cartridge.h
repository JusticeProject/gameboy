#include <stdint.h>
#include <stdbool.h>

bool init_cartridge();

bool set_address_bus(uint16_t addr);
void set_read_signal(bool level);
uint8_t get_data_bus();

void test_read_registers();
void test_write_registers();

void scan_bus();
