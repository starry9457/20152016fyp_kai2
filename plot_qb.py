'''
Plot the CDF of request completion times for short flows transfer
'''
from helper import *
import plot_defaults
import numpy as np

from matplotlib.ticker import MaxNLocator
from pylab import figure


parser = argparse.ArgumentParser()
parser.add_argument('--files', '-f',
                    help="Queue timeseries output to one plot",
                    required=True,
                    action="store",
                    nargs='+',
                    dest="files")

parser.add_argument('--legend', '-l',
                    help="Legend to use if there are multiple plots.  File names used as default.",
                    action="store",
                    nargs="+",
                    default=None,
                    dest="legend")

parser.add_argument('--out', '-o',
                    help="Output png file for the plot.",
                    default=None, # Will show the plot
                    dest="out")

parser.add_argument('--labels',
                    help="Labels for x-axis if summarising; defaults to file names",
                    required=False,
                    default=[],
                    nargs="+",
                    dest="labels")

parser.add_argument('--every',
                    help="If the plot has a lot of data points, plot one of every EVERY (x,y) point (default 1).",
                    default=1,
                    type=int)

parser.add_argument('--count',
                    help="Counts of data of transfer",
                    default=1000,
                    type=int)

parser.add_argument('--size',
                    help="Data size of each transfer",
                    default=20,
                    type=int)

args = parser.parse_args()

if args.legend is None:
    args.legend = []
    for file in args.files:
        args.legend.append(file)

to_plot=[]

def get_style(i):
    if i == 0:
        return {'color': 'red'}
    elif i == 1:
        return {'color': 'blue'}
    elif i == 2:
        return {'color': 'green'}
    elif i == 3:
        return {'color': 'black'}
    else:
        return {'color': 'orange'}


m.rc('figure', figsize=(16, 6))
fig = figure()
ax = fig.add_subplot(111)
for i, f in enumerate(args.files):
    data = read_list(f)
    xaxis = map(int, col(1, data))
    xaxis = map(lambda x: x , xaxis)
    
    xaxis = xaxis[::args.every]
    sorted_xaxis = np.sort(xaxis)
    
    cxaxis = np.cumsum(sorted_xaxis * .0001)
    cyaxis = np.arange(0, 1, (1.0 / args.count) )
    ax.plot(cxaxis, cyaxis, lw=2, **get_style(i))
    ax.xaxis.set_major_locator(MaxNLocator(8))

plt.legend(args.legend, 'lower right')
#plt.ylim([0,101])
plt.ylabel("CDF")
plt.grid(True)
plt.xlabel("Completion time of short transfer (ms)")
plt.title("CDF of request completion times for %d %d KB transfers" % (args.count, args.size) )

if args.out:
    print 'saving to', args.out
    plt.savefig(args.out)
else:
    plt.show()
