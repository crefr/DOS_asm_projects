#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "cracker.h"

enum crack_status crackProgram(const char * program_file_name)
{
    FILE * program_file = fopen(program_file_name, "rb+");

    if (program_file == NULL){
        fprintf(stderr, "File '%s' does not exist.\n", program_file_name);
        return NO_FILE;
    }

    swapBytes(program_file);
    swapToNop(program_file, 0x0003, 0x0006);      // nopping to the end of the program

    fclose(program_file);

    printf("CRACKED!!!\n");

    return SUCCESS;
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
