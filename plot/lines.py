#!/usr/bin/env python
import sys
import numpy as np
import matplotlib
import pylab
import random
from optparse import OptionParser

from matplotlib import rcParams
rcParams['font.family'] = 'Arial'

delim = '\t'
parser = OptionParser()

parser.add_option("-o",
                  "--output_file",
                  dest="output_file",
                  help="Data file")

parser.add_option("-l",
                  "--line_stype",
                  default='-o',
                  dest="line_style",
                  help="Line style (Default '-o')")


parser.add_option("--legend",
                  dest="legend",
                  help="Comma sperated legend")

parser.add_option("--title",
                  dest="title",
                  help="Title")

parser.add_option("--xlabel",
                  dest="xlabel",
                  help="X axis label")

parser.add_option("--ylabel",
                  dest="ylabel",
                  help="Y axis label")

parser.add_option( "--ylog",
                  action="store_true", 
                  default=False,
                  dest="ylog",
                  help="Y axis log")

parser.add_option("-X",
                  action="store_true", 
                  default=False,
                  dest="X",
                  help="X values includeded (Y line i, X line i+1)")

parser.add_option("--x_max",
                  dest="max_x",
                  type="float",
                  help="Max x value")

parser.add_option("--x_min",
                  dest="min_x",
                  type="float",
                  help="Min x value")


parser.add_option("--y_max",
                  dest="max_y",
                  type="float",
                  help="Max y value")

parser.add_option("--y_min",
                  dest="min_y",
                  type="float",
                  help="Min y value")

(options, args) = parser.parse_args()
if not options.output_file:
    parser.error('Output file not given')

matplotlib.rcParams.update({'font.size': 12})
fig = matplotlib.pyplot.figure(figsize=(5,5),dpi=300)
#fig.subplots_adjust(top=1.0)

ax = fig.add_subplot(1,1,1)


colors = [ 'blue', \
    'green', \
    'red', \
    'magenta', \
    'black']

color_i = 0
plts=[]
lines = sys.stdin.readlines()

if (options.X):
    for i in range(len(lines))[::2]:
        Y = [float(x) for x in lines[i].rstrip().split()]
        X = [float(x) for x in lines[i+1].rstrip().split()]
        p, = ax.plot(X,\
                     Y,\
                     options.line_style,\
                     color=colors[color_i],\
                     linewidth=1)
        plts.append(p)
        color_i = (color_i + 1) % len(colors)
else:
    for i in range(len(lines))[::1]:
        Y = [float(x) for x in lines[i].rstrip().split()]
        p, = ax.plot(range(len(Y)), \
                     Y,\
                     options.line_style,\
                     color=colors[color_i], \
                     linewidth=1)
        plts.append(p)
        color_i = (color_i + 1) % len(colors)

if options.ylog:
    ax.set_yscale('log')

if options.legend:
    ax.legend(plts, options.legend.split(","), frameon=False, fontsize=10)

if options.title:
    matplotlib.pyplot.suptitle(options.title)

if options.xlabel:
    ax.set_xlabel(options.xlabel)

if options.ylabel:
    ax.set_ylabel(options.ylabel)

if options.max_x:
    ax.set_xlim(xmax=options.max_x)
if options.min_x:
    ax.set_xlim(xmin=options.min_x)

if options.max_y:
    ax.set_ylim(ymax=options.max_y)
if options.min_y:
    ax.set_ylim(ymin=options.min_y)

ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.get_xaxis().tick_bottom()
ax.get_yaxis().tick_left()
#ax.legend()
matplotlib.pyplot.savefig(options.output_file,bbox_inches='tight')
