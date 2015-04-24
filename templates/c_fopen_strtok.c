#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main(int argc, char **argv)
{
    if (argc != 2) {
        fprintf(stderr,"usage:\t%s <file name>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    char *file_name = argv[1];
    FILE *fp;
    char *line = NULL;
    size_t len = 0;
    ssize_t read;
    char *pch;

    fp = fopen(file_name, "r");
    if (fp == NULL) {
        fprintf(stderr, "ERROR: Could not open %s\n", file_name);
        exit(EXIT_FAILURE);
    }

    while ((read = getline(&line, &len, fp)) != -1) {
        printf("Retrieved line of length %zu :\n", read);
        printf("%s", line);
        pch = strtok (line,"\t "); // split by either \t or space
        while (pch != NULL) {
            printf ("%s\n",pch);
            pch = strtok (NULL, "\t ");
        }
    }

    free(line);
    fclose(fp);
    exit(EXIT_SUCCESS);
}
