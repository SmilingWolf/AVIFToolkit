import os.path
import sys
import math

if len(sys.argv) != 2:
	print '%s <statsFile.qXX.txt>' % (sys.argv[0])
	sys.exit(1)

inFile = sys.argv[1]
statsFile = open(inFile, 'r')

statsDict = {}
for line in statsFile:
	filename, stats = line.rstrip().split(':')
	filename = os.path.basename(filename)
	filename = os.path.splitext(filename)[0]
	stats = stats.split(' ')[1:]
	statsList = []
	for item in stats:
		statsList.append(float(item.split('=')[1]))
	statsDict[filename] = statsList
statsFile.close()

totalPSNR = 0
totalSSIM = 0
totalMSSSIM = 0
totalPSNRHVS = 0
totalHVMAF = 0
totalDSSIM = 0
totalSSIMULACRA = 0
totalPixels = 0
totalSize = 0
for filename in statsDict:
	stats = statsDict[filename]
	totalPSNR += stats[1] * stats[2]
	totalSSIM += stats[1] * stats[3]
	totalPSNRHVS += stats[1] * stats[4]
	totalMSSSIM += stats[1] * stats[5]
	totalHVMAF += stats[1] * stats[6]
	totalDSSIM +=  stats[1] * stats[7]
	totalSSIMULACRA += stats[1] * stats[8]
	totalPixels += stats[1]
	totalSize += stats[0]
print('%s %d %d %0.4f %0.4f %0.4f %0.4f %0.4f %0.4f %0.4f' % (inFile.split('.')[-2],
totalPixels, totalSize,
totalPSNR/totalPixels, totalSSIM/totalPixels,
totalPSNRHVS/totalPixels, totalMSSSIM/totalPixels,
totalHVMAF/totalPixels,
(10*math.log10((1/(totalDSSIM/totalPixels)))),
(10*math.log10((1/(totalSSIMULACRA/totalPixels))))))
