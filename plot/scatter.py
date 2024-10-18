#!/usr/bin/env python
import sys
import argparse
import matplotlib.pyplot as plt
import plot_helper
import numpy as np

def get_args():
    parser = argparse.ArgumentParser(description='Plot a line graph')

    plot_helper.add_plot_args(parser)

    parser.add_argument("-a",
                        "--alpha",
                        type=float,
                        help="Alpha value")

    parser.add_argument("--markeredgecolor",
                        default="black",
                        help="Marker Edge Color")

    parser.add_argument("--markerfacecolor",
                        default="black",
                        help="Marker Face Color")

    parser.add_argument("--trend",
                        action="store_true", 
                        default=False,
                        help="Trend line")

    parser.add_argument("--point_size",
                        type=float,
                        default=1,
                        help="Scatter point size (defualt 1)")

    parser.add_argument("--line_style",
                        default=".",
                        help="Line style")

    return parser.parse_args()

def main():
    args = get_args()

    X=[]
    Y=[]
    E=[]
    for l in sys.stdin:
        #a = l.rstrip().split(delim)
        a = l.rstrip().split()
        if len(a) == 1:
            Y.append(float(a[0]))
        if len(a) == 2:
            X.append(float(a[0]))
            Y.append(float(a[1]))
        if len(a) == 3:
            X.append(float(a[0]))
            Y.append(float(a[1]))
            E.append(float(a[2]))

    fig, ax = plt.subplots(figsize=(args.width, args.height))


    p = None
    if len(X) == 0:
        p = ax.plot(range(len(Y)),
                    Y,
                    args.line_style,
                    markeredgecolor=args.markeredgecolor,
                    markerfacecolor=args.markerfacecolor,
                    linewidth=1)
    elif len(E) == 0:
        p = ax.plot(X,Y,
                    args.line_style,
                    markeredgecolor=args.markeredgecolor,
                    markerfacecolor=args.markerfacecolor,
                    linewidth=1,
                    alpha=args.alpha,
                    ms=float(args.point_size))
    else:
        p = ax.scatter(X, Y,
                       s=E,
                       alpha=args.alpha)

    if args.trend:
        z = np.polyfit(X, Y, 1)
        p = np.poly1d(z)
        ax.plot(X,p(Y),'--',color='black')

    plot_helper.format_ax(ax, args)

    plt.tight_layout()
    plt.savefig(args.output_file, transparent=args.transparent, dpi=300)

if __name__ == '__main__':
    main()
