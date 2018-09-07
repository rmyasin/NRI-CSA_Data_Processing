#!/usr/bin/env python

import rospy
import sys
from std_msgs.msg import Float32
from std_msgs.msg import Bool
from std_msgs.msg import Empty
from sensor_msgs.msg import JointState
from sensor_msgs.msg import Joy
from geometry_msgs.msg import Quaternion
from geometry_msgs.msg import PoseStamped
from enum import Enum
from cisst_msgs.msg import prmCartesianImpedanceGains

import os
import rospkg
import shutil
import re
import rosbag
import numpy as np

import ipdb

def locateInList(inlist,element):
	for i in range(len(inlist)):
		if inlist[i]==element:
			return i


# os.listdir()
bagFolder='/home/arma/catkin_ws/data/user14_Nabil_testablate/'
fileList=os.listdir(bagFolder) 


 ############################## Pick the filename to save and the bag name ##############################
# filename="NabilAug24_Visual1"
# regexbag=re.compile('^Following_Visual_2018-08-24-12-\w\w-42_\w.*\.bag')

# filename="NabilAug24_Visual2"
# regexbag=re.compile('^Following_Visual_2018-08-24-12-18-45_0.bag')

# filename="NabilAug24_Visual3"
# regexbag=re.compile('^Following_Visual_2018-08-24-12-24-06_0.bag')
 ############################## ############################## ##############################

filename="NabilAug24_Direct"
regexbag=re.compile('^Following_DirectForce_2018-08-24-12-.*\.bag')


newlist=filter(regexbag.match,fileList)
ipdb.set_trace()
bagNumbers=[temp[-5] for temp in newlist]

orderedList=list()
for i in range(len(bagNumbers)):
	orderedList.append(locateInList(bagNumbers,str(i)))

dataLists = {'force':[],'psm_cur':[],'mtm_cur':[],'camera':[]}
timeLists = {'force':[],'psm_cur':[],'mtm_cur':[],'camera':[]}
topicNames= {	'force':	'/dvrk/PSM2/wrench',
				'psm_cur':	'/dvrk/PSM2/position_cartesian_current',
				'mtm_cur':	'/dvrk/MTMR/position_cartesian_current',
				'camera' :	'/dvrk/footpedals/camera',
			}

topicList=topicNames.values()

for i in orderedList:
	bagname = newlist[i]
	bag = rosbag.Bag(bagFolder +bagname)
	for topic, msg, t in bag.read_messages(topics=topicList):
		if topic == topicNames['force']:
			dataLists['force'].append([msg.wrench.force.x,msg.wrench.force.y,msg.wrench.force.z])
			timeLists['force'].append(t)
		elif topic == topicNames['psm_cur']:
			dataLists['psm_cur'].append([msg.pose.position.x*1000,msg.pose.position.y*1000,msg.pose.position.z*1000])
			timeLists['psm_cur'].append(t)
		elif topic == topicNames['mtm_cur']:
			dataLists['mtm_cur'].append([msg.pose.position.x*1000,msg.pose.position.y*1000,msg.pose.position.z*1000])
			timeLists['mtm_cur'].append(t)
		elif topic == topicNames['camera']:
			dataLists['camera'].append(msg.buttons)
			timeLists['camera'].append(t)

# ipdb.set_trace()
f=open(filename+'.txt','w')

for topicName in topicNames.keys():
	f.write(topicName+'\n')
	for i in range(len(dataLists[topicName])):
		f.write(str(timeLists[topicName][i])+" "+" ".join(str(x) for x in dataLists[topicName][i]) +"\n")
f.close()

