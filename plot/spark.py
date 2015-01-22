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

Y=[]
for l in sys.stdin:
    Y.append([float(x) for x in l.split()])

matplotlib.rcParams.update({'font.size': 12})
fig = matplotlib.pyplot.figure(figsize=(5,10),dpi=300)
fig.subplots_adjust(wspace=.05,left=.01,bottom=.01)

N = len(Y)
i = 1

for y in Y:
    ax = fig.add_subplot(N,1,i)
    ax.plot(range(len(y)),y,options.line_style,color='black', linewidth=1)

    if options.logy:
        ax.set_yscale('log')

    ax.set_yticklabels([])

    if ((options.max_y) and (options.min_y)):
        ax.set_ylim(float(options.min_y),float(options.max_y))

    i+=1

matplotlib.pyplot.savefig(options.output_file,bbox_inches='tight')
