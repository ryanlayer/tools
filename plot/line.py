#!/usr/bin/env python
import sys
import numpy as np
import matplotlib
import pylab
import random
from optparse import OptionParser

delim = '\t'
parser = OptionParser()

parser.add_option("-o",
                  "--output_file",
                  dest="output_file",
                  help="Data file")

parser.add_option("-l",
                  "--legend",
                  dest="legend",
                  help="Comma sperated legend")

parser.add_option("-t",
                  "--title",
                  dest="title",
                  help="Title")

parser.add_option("-x",
                  "--xlabel",
                  dest="xlabel",
                  help="X axis label")

parser.add_option("-y",
                  "--ylabel",
                  dest="ylabel",
                  help="Y axis label")

parser.add_option( "--ylog",
                  action="store_true", 
                  default=False,
                  dest="ylog",
                  help="Y axis log")



(options, args) = parser.parse_args()
if not options.output_file:
    parser.error('Output file not given')

matplotlib.rcParams.update({'font.size': 12})
fig = matplotlib.pyplot.figure(figsize=(5,5),dpi=300)
#fig.subplots_adjust(top=1.0)

ax = fig.add_subplot(1,1,1)


color_i = 0
plts=[]
X = []
Y = []
for l in sys.stdin:
    x,y = [float(x) for x in l.rstrip().split()]
    X.append(X)
    Y.append(y)

print len(X), len(Y)
p, = ax.plot(X,Y,'-o',linewidth=1)

if options.ylog:
    ax.set_yscale('log')

if options.legend:
    ax.legend(plts, options.legend.split(","))

if options.title:
    matplotlib.pyplot.suptitle(options.title)

if options.xlabel:
    ax.set_xlabel(options.xlabel)

if options.ylabel:
    ax.set_ylabel(options.ylabel)
#ax.legend()
matplotlib.pyplot.savefig(options.output_file,bbox_inches='tight')
