#ifndef CRACKER_INCLUDED
#define CRACKER_INCLUDED

typedef struct {
    short int addr;
    unsigned char new_byte;
} byte_swap_t;

const byte_swap_t swap_table[] = {
    {.addr = 0x0001, .new_byte = 0x5C}          // call TakePassword -> call AccessGranted
};
const size_t swap_table_size = sizeof(swap_table) / sizeof(swap_table[0]);

void crackProgram(void);

/// @brief swaps bytes as in swap_table
void swapBytes(FILE * program_file);

/// @brief swap bytes from nop_start to nop_end (not inclusive) by NOP
void swapToNop(FILE * program_file, short nop_start, short nop_end);

const unsigned char NOP = 0x90;

#endif
