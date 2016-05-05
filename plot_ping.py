'''
Plot ping vs marking threshold
'''
from helper import *
from collections import defaultdict
import plot_defaults
import copy

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

parser.add_argument('--tos',
                    help="Type of Service (Tos)", 
                    required=False,
                    default=0,
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
    else:
        return {'color': 'blue', 'ls': '-.'}

def parse_file(file, tos):
    ks = []
    rtts = []
    found = False
    for l in open(file).xreadlines():
        l = l.strip()
        if (l == "TOS: %d" % tos):
            found = True
            continue
        else:
            if (found):
                fields = l.split(',')
                if fields[0].find("TOS") == -1:
                    ks.append(int(fields[0]))
                    rtts.append(float(fields[1]))
                else:
                    found = False
                    break
            else:
                continue
    return ks, rtts

m.rc('figure', figsize=(16, 6))
fig = figure()
ax = fig.add_subplot(121)
for i, f in enumerate(args.files):
    ks, rtts = parse_file(f, args.tos)
    xks = ks[::args.every]
    yrtts = rtts[::args.every]
    ax.plot(xks, yrtts, lw=2, **get_style(i))
    ax.xaxis.set_major_locator(MaxNLocator(8))

plt.legend(args.legend, bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)
plt.ylabel("RTT (ms)")
plt.grid(True)
plt.xlabel("Marking Thresholds (k)")
plt.title("Round-trip Time under different Marking Thresholds, ToS = %d" % (args.tos) )

if args.out:
    print 'saving to', args.out
    plt.savefig(args.out)
else:
    plt.show()
