#include <stdint.h>
#include <stdbool.h>

bool init_cartridge();

void set_address(uint16_t addr);
void set_read_signal(bool level);
uint8_t get_data();

void test_read_registers();
void test_write_registers();

void scan_bus();
