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

I=[]
for l in sys.stdin:
    i = []
    A = l.rstrip().split('\t')
    for a in A:
        i.append([int(a.split(' ')[0]),int(a.split(' ')[1])])
    I.append(i)

matplotlib.rcParams.update({'font.size': 12})
fig = matplotlib.pyplot.figure(figsize=(10,5),dpi=300)
fig.subplots_adjust(wspace=.05,left=.01,bottom=.01)

ax = fig.add_subplot(1,1,1)

c = 0
for i in I:
    fudge = 0.1
    for a in i:
        fudge *= -1
        ax.plot(a,[c*-1 + fudge ,c*-1 + fudge ],'.-',color='green')
    c+=1

if options.xmin and options.xmax:
    ax.set_xlim([options.xmin,options.xmax])

ax.set_ylim([-4.2,0])
ax.set_xticklabels([])
ax.set_yticklabels([])
matplotlib.pyplot.tick_params(axis='x',length=0)
matplotlib.pyplot.tick_params(axis='y',length=0)
matplotlib.pyplot.box(on=None)

matplotlib.pyplot.savefig(options.output_file,bbox_inches='tight')
