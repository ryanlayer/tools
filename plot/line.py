#!/usr/bin/env python
import sys
import argparse
import matplotlib.pyplot as plt
import plot_helper

def get_args():
    parser = argparse.ArgumentParser(description='Plot a line graph')

    plot_helper.add_plot_args(parser)

    parser.add_argument("--line_color",
                        default="black",
                        help="Line color")

    return parser.parse_args()

def main():
    args = get_args()

    fig, ax = plt.subplots(figsize=(args.width, args.height))

    X = []
    Y = []
    for l in sys.stdin:
        x,y = [float(x) for x in l.rstrip().split()]
        X.append(x)
        Y.append(y)

    ax.plot(X, Y, color=args.line_color)

    plot_helper.format_ax(ax, args)

    plt.tight_layout()
    plt.savefig(args.output_file, transparent=args.transparent, dpi=300)

if __name__ == '__main__':
    main()
