#include <unistd.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int usage(char *prog)
{
    fprintf(stderr, "usage:\t%s <options> [command]\n"
                    "\t\t-f\tFile name\n"
                    "\t\t-n\tNumber\n",
                    prog);
    return 1;
}

int main(int argc, char **argv)
{
    char *file_name;
    int num;

    int f_is_set = 0,
        n_is_set = 0,
        h_is_set = 0;

    int c;

    while ((c = getopt (argc, argv, "hn:f:")) != -1) {
        switch (c) {
        case 'h':
            h_is_set = 1;
            break;
        case 'f':
            f_is_set = 1;
            file_name = optarg;
            break;
        case 'n':
            n_is_set = 1;
            num = atoi(optarg);
            break;
        case '?':
            if ( (optopt == 'f') ||
                 (optopt == 'n') )
                fprintf (stderr, "Option -%c requires an argument.\n",
                         optopt);
            else if (isprint (optopt))
                fprintf (stderr, "Unknown option `-%c'.\n", optopt);
            else
                fprintf (stderr, "Unknown option character `\\x%x'.\n", optopt);
        default:
            return usage(argv[0]);
        }
    }

    if (h_is_set)
        return usage(argv[0]);

    if (!f_is_set) {
        fprintf(stderr, "File name is not set.\n");
        return usage(argv[0]);
    }

    if (!n_is_set) {
        fprintf(stderr, "Number is not set.\n");
        return usage(argv[0]);
    }

    if (optind == argc) {
        fprintf(stderr, "No command given\n");
        return usage(argv[0]);
    }

    char *cmd = argv[optind];
    optind+=1;

    if (optind < argc) {
        int index;
        for (index = optind; index < argc; index++)
            printf ("Non-option argument %s\n", argv[index]);
        return usage(argv[0]);
    }

    printf("file name:%s\tnumber:%d\tcommand:%s\n", file_name, num, cmd);

    return 0;
}
