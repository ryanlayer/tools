#!/usr/bin/env python
import sys
import numpy as np

from optparse import OptionParser

def prog():
    parser = OptionParser()

    parser.add_option("-d",
        "--data_file",
        dest="data_file",
        help="Data file")

    (options, args) = parser.parse_args()

    if not options.data_file:
        parser.error('Data file not given')

    f = open(options.data_file,'r')

    for l in f:
        A = l.rstrip().split('\t')

    f.close()

def main():
    try:
        prog();
    except IOError as err:
        sys.stderr.write("IOError " + str(err) + '\n');
        return;
    except StandardError as err:
        sys.stderr.write("StandardError\n");
        handleException(err);
        sys.exit(1);

if __name__ == "__main__":
    sys.exit(main())
    (END)
