#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "cracker.h"

extern FILE * G_program_file;

void crackProgram(void)
{
    swapBytes(G_program_file);
    swapToNop(G_program_file, 0x000A, 0x0019);

    printf("CRACKED!!!\n");
}

void swapBytes(FILE * program_file)
{
    for (size_t swap_index = 0; swap_index < swap_table_size; swap_index++){
        fseek(program_file, (long)swap_table[swap_index].addr, SEEK_SET);

        fputc(swap_table[swap_index].new_byte, program_file);
    }
}

void swapToNop(FILE * program_file, short nop_start, short nop_end)
{
    fseek(program_file, nop_start, SEEK_SET);

    for (size_t nop_index = nop_start; nop_index < nop_end; nop_index++){
        fputc(NOP, program_file);
    }
}
