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
(options, args) = parser.parse_args()
if not options.output_file:
    parser.error('Output file not given')

X=[]
Y=[]
for l in sys.stdin:
    a = l.rstrip().split(delim)
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
    ax.plot(range(len(Y)),Y,'.',color='black', linewidth=0)
else:
    ax.plot(X,Y,'.',color='black', linewidth=0)

matplotlib.pyplot.savefig(options.output_file,bbox_inches='tight')
