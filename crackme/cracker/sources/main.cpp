#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "window_handler.h"
#include "cracker.h"

//! WARNING: GLOBAL VALUE
FILE * G_program_file = NULL;

int main(int argc, char ** argv)
{
    if (argc == 1){
        fprintf(stderr, "No input file.\n");
        return 0;
    }

    const char * file_name = argv[1];
    // FILE * program_file = fopen(file_name, "rb+");
    G_program_file = fopen(file_name, "rb+");

    if (G_program_file == NULL){
        fprintf(stderr, "File '%s' does not exist.\n", file_name);
        return 0;
    }

    SFML_window();

    fclose(G_program_file);

    return 0;
}


