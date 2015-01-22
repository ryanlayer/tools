#!/usr/bin/env python
import sys
import numpy as np
import matplotlib
import pylab
import random
from optparse import OptionParser

delim = '\t'
parser = OptionParser()

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

parser.add_option("--line_style",
                  dest="line_style",
                  default=".",
                  help="Line style")



(options, args) = parser.parse_args()
if not options.output_file:
    parser.error('Output file not given')

X=[]
Y=[]
for l in sys.stdin:
    #a = l.rstrip().split(delim)
    a = l.rstrip().split()
    if len(a) == 1:
        Y.append(a[0])
    if len(a) == 2:
        X.append(a[0])
        Y.append(a[1])


matplotlib.rcParams.update({'font.size': 12})
fig = matplotlib.pyplot.figure(figsize=(5,5),dpi=300)
fig.subplots_adjust(wspace=.05,left=.01,bottom=.01)

ax = fig.add_subplot(1,1,1)
if len(X) == 0:
    ax.plot(range(len(Y)),Y,options.line_style,color='black', linewidth=1)
else:
    ax.plot(X,Y,options.line_style,color='black', linewidth=1)

if options.logy:
    ax.set_yscale('log')

if ((options.max_y) and (options.min_y)):
    ax.set_ylim(float(options.min_y),float(options.max_y))

if len(X) != 0:
    ax.set_xticks([float(x) for x in X])
    #ax.set_xticklabels

matplotlib.pyplot.savefig(options.output_file,bbox_inches='tight')
