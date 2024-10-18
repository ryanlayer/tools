#!/usr/bin/env python
import sys
import argparse
import matplotlib.pyplot as plt
import plot_helper

def get_args():
    parser = argparse.ArgumentParser(description='Plot a line graph')

    plot_helper.add_plot_args(parser)


    parser.add_argument("--density",
                        action="store_true",default=False,
                        help="Plot density")

    parser.add_argument("--bins",
                        default=10,
                        help="Number of bins or csv of bins")

    parser.add_argument("--bar_color",
                      default="black",
                      help="Bar color")

    parser.add_argument("--column",
                        type=int,
                        default="0",
                        help="Column in the data")

    parser.add_argument("--delim",
                        default="\t",
                        help="Field delimiter")

    return parser.parse_args()

def main():
    args = get_args()

    fig, ax = plt.subplots(figsize=(args.width, args.height))

    Y=[]
    for l in sys.stdin:
        a = l.rstrip().split(args.delim)
        if len(a) == 1:
            if len(a[args.column]) != 0 :
                Y.append(float(a[args.column]))


    h = ax.hist(Y, \
                bins=args.bins, \
                density=args.density,
                log=args.ylog, \
                histtype='bar', \
                rwidth=0.8, \
                color=args.bar_color)

    plot_helper.format_ax(ax, args)

    plt.tight_layout()
    plt.savefig(args.output_file, transparent=args.transparent, dpi=300)

if __name__ == '__main__':
    main()
