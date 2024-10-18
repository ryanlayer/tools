import numpy as np

def format_ax(ax, args):
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_color(args.axis_color)
    ax.spines['bottom'].set_color(args.axis_color)
    ax.tick_params(axis='both',
                   which='major',
                   labelsize=args.axis_label_size,
                   width=args.tick_line_width,
                   length=args.tick_line_length,
                   color=args.axis_color,
                   colors=args.axis_color)

    if args.ylog:
        ax.set_yscale('log')

    if args.xlog:
        ax.set_xscale('log')

    if args.title:
        if ';' in args.title:
            text, size, loc = args.title.split(';')
            fontdict = {'fontsize':int(size)}
            ax.set_title(text,
                         fontdict=fontdict,
                         loc=loc,
                         color=args.axis_color)
        else:
            ax.set_title(args.title, color=args.axis_color)

    if args.xlabel:
        ax.set_xlabel(args.xlabel, color=args.axis_color)

    if args.ylabel:
        ax.set_ylabel(args.ylabel, color=args.axis_color)

    if args.noxticks:
        ax.tick_params(axis='x', which='both',length=0)

    if args.noyticks:
        ax.tick_params(axis='y', which='both',length=0)

    if args.noxline:
        ax.spines['bottom'].set_visible(False)

    if args.noyline:
        ax.spines['left'].set_visible(False)

    if args.noxtick_labels:
        ax.set_xticklabels([])

    if args.noytick_labels:
        ax.set_yticklabels([])

    ax.get_xaxis().tick_bottom()
    ax.get_yaxis().tick_left()

    if args.y_max:
        ax.set_ylim(ymax=args.y_max)

    if args.y_min:
        ax.set_ylim(ymin=args.y_min)

    if args.x_max:
        ax.set_xlim(xmax=args.x_max)

    if args.x_min:
        ax.set_xlim(xmin=args.x_min)

    if args.axhline:
        for hv in [float(x) for x in args.axhline.split(",")]:
            ax.axhline(y=hv, lw=0.5, color=args.axis_color)

    if args.axvline:
        for hv in [float(x) for x in args.axvline.split(",")]:
            ax.axvline(x=hv, lw=0.5, color=args.axis_color)

    if args.xticks:
        x_tick_lables = args.xticks.split(',') 
        ax.set_xticks(range(len(x_tick_lables)))
        ax.set_xticklabels(x_tick_lables, rotation=args.xrotation)


    if args.ref_lines:
        for slope,intercept,style,color,weight in [x.split(':') for x in args.ref_lines.split(',')]:
            x_vals = np.array(ax.get_xlim())
            y_vals = float(intercept) + float(slope) * x_vals
            ax.plot(x_vals, y_vals, style, c=color, lw=float(weight))

    if args.annotate:
        for vals in  args.annotate.split(','):
            val = vals.split(':')
            x_min = ax.get_xlim()[0]
            x_max = ax.get_xlim()[1]
            x_loc = x_min + (x_max - x_min) * float(val[0])
            y_min = ax.get_ylim()[0]
            y_max = ax.get_ylim()[1]
            y_loc = y_min + (y_max - y_min) * float(val[1])
            if len(val) == 4:
                ax.text(x_loc,y_loc,val[2], color=val[3])
            if len(val) == 6:
                x_arrow = ax.get_xlim()[0] \
                          + (ax.get_xlim()[1] - ax.get_xlim()[0]) \
                          * float(val[4])
                y_arrow = ax.get_ylim()[0] \
                          + (ax.get_ylim()[1] - ax.get_ylim()[0]) \
                          * float(val[5])
                ax.annotate(val[2],
                            xy=(x_arrow, y_arrow),
                            xytext=(x_loc,y_loc),
                            color=val[3],
                            arrowprops=dict(arrowstyle="->",
                                            color=val[3]))
 
    if args.x_sci:
        formatter = matplotlib.ticker.ScalarFormatter()
        formatter.set_powerlimits((-2,2))
        ax.xaxis.set_major_formatter(formatter)
    
    if args.y_sci:
        formatter = matplotlib.ticker.ScalarFormatter()
        formatter.set_powerlimits((-2,2))
        ax.yaxis.set_major_formatter(formatter)

def add_plot_args(parser):
    parser.add_argument("-o",
                        "--output_file",
                        help="Data file")

    parser.add_argument("-t",
                        "--title",
                        help="Plot title (title or title;size;location)")

    parser.add_argument("-x",
                        "--xlabel",
                        help="X axis label")

    parser.add_argument("-y",
                        "--ylabel",
                        help="Y axis label")

    parser.add_argument("--ylog",
                        action="store_true", 
                        default=False,
                        help="Y axis log")

    parser.add_argument("--xlog",
                        action="store_true", 
                        default=False,
                        help="X axis log")


    parser.add_argument("--tick_line_length",
                      type=float,
                      default=2,
                      help="Tick line width")

    parser.add_argument("--tick_line_width",
                      type=float,
                      default=0.5,
                      help="Tick line width")

    parser.add_argument("--axis_line_width",
                      type=float,
                      default=0.5,
                      help="Axis line width")

    parser.add_argument("--axis_label_size",
                      type=int,
                      default=8,
                      help="Axis label font size")

    parser.add_argument("--tick_label_size",
                      type=int,
                      default=8,
                      help="Axis tick label font size")

    parser.add_argument("--axis_color",
                        default="black",
                        help="Axis color")

    parser.add_argument("--height",
                        type=float,
                        default=3,
                        help="Height of the figure")

    parser.add_argument("--width",
                        type=float,
                        default=4,
                        help="Width of the figure")

    parser.add_argument("--transparent",
                        action="store_true", 
                        default=False,
                        help="Transparent background")


    parser.add_argument("--noxline",
                      action="store_true", 
                      default=False,
                      help="No X axsis line")

    parser.add_argument("--noyline",
                      action="store_true", 
                      default=False,
                      help="No Y axsis line")

    parser.add_argument("--noxticks",
                      action="store_true", 
                      default=False,
                      help="No X axsis ticks")

    parser.add_argument("--noyticks",
                      action="store_true", 
                      default=False,
                      help="No Y axsis ticks")

    parser.add_argument("--noxtick_labels",
                      action="store_true", 
                      default=False,
                      help="No X axsis labels")

    parser.add_argument("--noytick_labels",
                      action="store_true", 
                      default=False,
                      help="No Y axsis labels")


    parser.add_argument("--y_min",
                        type=float,
                        help="Min y value")

    parser.add_argument("--y_max",
                        type=float,
                        help="Max y value")

    parser.add_argument("--x_min",
                        type=float,
                        help="Min x value")

    parser.add_argument("--x_max",
                        type=float,
                        help="Max x value")

    parser.add_argument("--axhline",
                        help="Horizonal line CSV")

    parser.add_argument("--axvline",
                        help="Vertical line CSV")

    parser.add_argument("--xticks",
                        help="X axis tick labels CSV")

    parser.add_argument("--xrotation",
                        type=int,
                        default=0,
                        help="X axis tick label rotation")

    parser.add_argument("--ref_lines",
                        help="Reference lines slope:intercept:style:color:weight")

    parser.add_argument("--annotate",
                        dest="annotate",
                        help="CSV of text annotation in %%x:%%y:txt:color,... or %%x:%%y:txt:color:%%x_arrow:%%y_arrow,...")

    parser.add_argument("--x_sci",
                       action="store_true",default=False,
                       help="Use scientific notation for x-axis")

    parser.add_argument("--y_sci",
                        action="store_true",default=False,
                        help="Use scientific notation for y-axis")


