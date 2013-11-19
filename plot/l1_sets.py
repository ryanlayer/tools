#!/usr/bin/env python
import sys
import numpy as np
import matplotlib
import pylab
import random
from optparse import OptionParser

parser = OptionParser()

parser.add_option("-a",
                  "--xmin",
                  type="int",
                  dest="xmin",
                  help="Data file")

parser.add_option("-b",
                  "--xmax",
                  type="int",
                  dest="xmax",
                  help="Data file")


parser.add_option("-o",
                  "--output_file",
                  dest="output_file",
                  help="Data file")
(options, args) = parser.parse_args()
if not options.output_file:
    parser.error('Output file not given')

matplotlib.rcParams.update({'font.size': 12})
fig = matplotlib.pyplot.figure(figsize=(10,5),dpi=300)
fig.subplots_adjust(wspace=.05,left=.01,bottom=.01)

ax = fig.add_subplot(1,1,1)

colors = [ 'blue', \
           'green', \
           'red', \
           'magenta', \
           'black']
c = 0;
color_i = 0
for l in sys.stdin:
    A = l.rstrip().split('\t')
    c = len(A)
    for i in range(len(A)):
        fudge = 0.1
        for a in A[i].split(';'):
            x=[int(a.split(',')[0]),int(a.split(',')[1])]
            fudge *= -1
            print x,[i*-1 + fudge ,i*-1 + fudge ]
            ax.plot(x,[i*-1 + fudge ,i*-1 + fudge ],'.-',color=colors[color_i])
    color_i = (color_i + 1) % len(colors)
#c = 1
#for i in I:
#    fudge = 0.1
#    for a in i:
#        fudge *= -1
#        ax.plot(a,[c + fudge ,c + fudge ],'.-',color='black')
#    c+=1

if options.xmin and options.xmax:
    ax.set_xlim([options.xmin,options.xmax])

ax.set_ylim([-4.2,0])
ax.set_xticklabels([])
ax.set_yticklabels([])
matplotlib.pyplot.tick_params(axis='x',length=0)
matplotlib.pyplot.tick_params(axis='y',length=0)
matplotlib.pyplot.box(on=None)
matplotlib.pyplot.savefig(options.output_file,bbox_inches='tight')
