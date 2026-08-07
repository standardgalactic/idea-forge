#include <stdint.h>

void kernel_main(void) {
    volatile uint16_t *vga = (uint16_t *)0xB8000;
    const char *msg = "tiny-operating-systems";

    for (int i = 0; msg[i] != '\0'; ++i) {
        vga[i] = (uint16_t)msg[i] | 0x0F00;
    }
}
