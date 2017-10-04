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

parser.add_option("--numyticks",
                  dest="numyticks",
                  help="Number of Y ticks")

parser.add_option("--xrotation",
                  dest="xrotation",
                  type=int,
                  default=0,
                  help="x axis tick rotation (default 0)")


parser.add_option("--xticks",
                  dest="xticks",
                  help="CSV of x tick lables")

parser.add_option("--title",
                  dest="title",
                  help="Title")

parser.add_option("--xlabel",
                  dest="xlabel",
                  help="X axis label")

parser.add_option("--ylabel",
                  dest="ylabel",
                  help="Y axis label")

parser.add_option("--lw",
                  dest="lw",
                  type=int,
                  default=5,
                  help="line width")



parser.add_option("-a",
                  "--annotate",
                  dest="annotate",
                  help="CSV of text annotation in %x:%y:txt:font,...")


parser.add_option("-l",
                  "--log_y",
                  action="store_true", dest="logy", default=False,
                  help="Use log scale for y-axis")

parser.add_option("-o",
                  "--output_file",
                  dest="output_file",
                  help="Data file")

parser.add_option("--y_min",
                  dest="min_y",
                  help="Min y value")

parser.add_option("--y_max",
                  dest="max_y",
                  help="Max y value")

parser.add_option("--x_min",
                  dest="min_x",
                  help="Min x value")

parser.add_option("--x_max",
                  dest="max_x",
                  help="Max x value")


parser.add_option("--line_style",
                  dest="line_style",
                  default=".",
                  help="Line style")

parser.add_option("--fig_x",
                  dest="fig_x",
                  type="int",
                  default=5,
                  help="Figure width")

parser.add_option("--fig_y",
                  dest="fig_y",
                  type="int",
                  default=5,
                  help="Figure height")

parser.add_option("-b",
                  action="store_true", 
                  default=False,
                  dest="black",
                  help="black background")

parser.add_option("--noxtick",
                  action="store_true", 
                  default=False,
                  dest="noxtick",
                  help="No X ticks")

parser.add_option("--noytick",
                  action="store_true", 
                  default=False,
                  dest="noytick",
                  help="No Y ticks")


parser.add_option("-c",
                  "--color",
                  dest="color",
                  default="black",
                  help="Color")

(options, args) = parser.parse_args()
if not options.output_file:
    parser.error('Output file not given')

X=[]
Y=[]
for l in sys.stdin:
    #a = l.rstrip().split(delim)
    a = l.rstrip().split()
    if len(a) == 2:
        X.append(a[0])
    #Y.append([a[1],a[2]])
        Y.append(a[1])
    else:
        Y.append(a[0])

if len(X) == 0:
    X = range(len(Y))


matplotlib.rcParams.update({'font.size': 12})
#fig = matplotlib.pyplot.figure(figsize=(options.fig_x,options.fig_y),dpi=300)
fig = 1
if options.black:
    fig = matplotlib.pyplot.figure(\
            figsize=(options.fig_x,options.fig_y),\
            dpi=300,\
            facecolor='black')
else:
    fig = matplotlib.pyplot.figure(\
            figsize=(options.fig_x,options.fig_y),\
            dpi=300)

fig.subplots_adjust(wspace=.05,left=.01,bottom=.01)

#ax = fig.add_subplot(1,1,1)
ax = 1
if options.black:
    ax = fig.add_subplot(1,1,1,axisbg='k')
else:
    ax = fig.add_subplot(1,1,1)

ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['bottom'].set_visible(False)

if options.black:
    ax.spines['bottom'].set_color('white')
    ax.spines['left'].set_color('white')
    ax.title.set_color('white')
    ax.yaxis.label.set_color('white')
    ax.xaxis.label.set_color('white')
    ax.tick_params(axis='x', colors='white')
    ax.tick_params(axis='y', colors='white')
ax.get_xaxis().tick_bottom()
ax.get_yaxis().tick_left()

bar_color=options.color

if len(bar_color.split(',')) > 1:
    bar_color=bar_color.split(',')
    for i in range(len(X)):
        ax.plot( [X[i],X[i]], [0,Y[i]], color=bar_color[i], lw = options.lw)
else:
    for i in range(len(X)):
        ax.plot( [X[i],X[i]], [0,Y[i]], color=bar_color, lw = options.lw)


if options.annotate:
    for vals in  options.annotate.split(','):
        val = vals.split(':')
        x_txt = ax.get_xlim()[1] * float(val[0])
        y_txt = ax.get_ylim()[1] * float(val[1])
        #font = val[3] if len(val) == 4 else 12
        if len(val) == 3:
            ax.text(x_txt,y_txt,val[2])
        else:
            x_arrow = ax.get_xlim()[1] * float(val[3])
            y_arrow = ax.get_ylim()[1] * float(val[4])
            ax.annotate(val[2],
                        xy=(x_arrow, y_arrow),
                        xytext=(x_txt,y_txt),
                        arrowprops=dict(arrowstyle="->",
                                        facecolor='black'))


if options.logy:
    ax.set_yscale('log')

if ((options.max_y) and (options.min_y)):
    ax.set_ylim(float(options.min_y),float(options.max_y))

if ((options.max_x) and (options.min_x)):
    ax.set_xlim(float(options.min_x),float(options.max_x))

if options.title:
    matplotlib.pyplot.suptitle(options.title)

if options.xlabel:
    ax.set_xlabel(options.xlabel)

if options.ylabel:
    ax.set_ylabel(options.ylabel)

if options.numyticks:
    matplotlib.pyplot.locator_params(axis = 'y', nbins = int(options.numyticks))

if options.xticks:
    #matplotlib.pyplot.locator_params(axis = 'x',  \
            #nbins = int(len(options.xticks.split(','))))
    matplotlib.pyplot.locator_params(axis = 'x', nbins = int(len(options.xticks.split(','))))
    ax.set_xticklabels(options.xticks.split(','), rotation=options.xrotation, size=8)
    print options.xticks.split(',')
#
if options.noxtick:
    ax.set_xticklabels([])

if options.noytick:
    ax.set_yticklabels([])

#if len(X) != 0:
#    ax.set_xticks([float(x) for x in X])
#    #ax.set_xticklabels

#matplotlib.pyplot.savefig(options.output_file,bbox_inches='tight')

if options.black:
    matplotlib.pyplot.savefig(options.output_file,bbox_inches='tight',\
            facecolor=fig.get_facecolor(),\
              transparent=True)
else:
    matplotlib.pyplot.tight_layout()
    matplotlib.pyplot.savefig(options.output_file,bbox_inches='tight')
