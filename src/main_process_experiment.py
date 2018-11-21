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


def getMatchingRosBags(folder,bagName):
	dateEnd=bagName.rfind('_') 
	dateStart=dateEnd-19
	matchName=bagName[0:dateStart] # Find beginning string of the bag
	regexbag=re.compile('^'+matchName) # Find all bags with the same string

	fileList=os.listdir(folder) 
	newList=filter(regexbag.match,fileList)
	bagNumbers=[temp[-5] for temp in newList]

	# Find the dates of all bags in the folder and sort by date
	dateList=list()
	numberList=list()
	for temp in newList:
		dotIndex=temp.rfind('.')
		dateEnd=temp.rfind('_')
		dateStart=dateEnd-19
		dateList.append(temp[dateStart:dateEnd])
		numberList.append(temp[dateEnd+1:dotIndex])
	tupleList=zip(dateList,numberList,newList)
	sortedTuple=sorted(tupleList, key=lambda entry:map(int, entry[0].split('-')))

	# Add the bags to the list of bags to process in date order
	bagList=[bagName]
	found =0
	for curTuple in sortedTuple:
		if found>0:
			if curTuple[1] == '0':
				found=-1
			else:
				bagList.append(curTuple[2])
		if curTuple[2]==bagName:
			found=1
	return bagList


filename= 'testOutput'
bagFolder = '/home/arma/catkin_ws/data/user24/'
findBag='Palpation_DirectForce_2018-10-02-11-27-20_0.bag'

# Find all bags in a sequence of auto-saved bags
bagList=getMatchingRosBags(bagFolder,findBag)

# Set up lists of data to save and corresponding topics
dataLists = {'force':[],'psm_cur':[],'mtm_cur':[],'camera':[],'psm_des':[],'micronTip':[],'micron':[],'psm_joint':[]}
timeLists = {'force':[],'psm_cur':[],'mtm_cur':[],'camera':[],'psm_des':[],'micronTip':[],'micron':[],'psm_joint':[]}
topicNames= {	'force':	'/dvrk/PSM2/wrench',
				'psm_cur':	'/dvrk/PSM2/position_cartesian_current',
				'mtm_cur':	'/dvrk/MTMR/position_cartesian_current',
				'camera' :	'/dvrk/footpedals/camera',
				'psm_des': 	'/dvrk/PSM2/position_cartesian_desired',
				'micronTip' :	'/MicronTipPose',
				'psm_joint':'/dvrk/PSM2/state_joint_current',
				'A' :		'/A',
				'B' :		'/B',
				'C' :		'/C',
				'D' :		'/D',
				'Ref' :		'/Ref',
			}

topicList=topicNames.values()

# Fill lists of each data type
for bagName in bagList:
	bag = rosbag.Bag(bagFolder +bagName)
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
		elif topic == topicNames['psm_des']:
			dataLists['psm_des'].append([msg.pose.position.x*1000,msg.pose.position.y*1000,msg.pose.position.z*1000,msg.pose.orientation.w,msg.pose.orientation.x,msg.pose.orientation.y,msg.pose.orientation.z])
			timeLists['psm_des'].append(t)
		elif topic == topicNames['micronTip']:
			dataLists['micronTip'].append([msg.pose.position.x,msg.pose.position.y,msg.pose.position.z,msg.pose.orientation.w,msg.pose.orientation.x,msg.pose.orientation.y,msg.pose.orientation.z,msg.header.seq])
			timeLists['micronTip'].append(t)
		elif topic == topicNames['A'] or topic == topicNames['B'] or topic == topicNames['C'] or topic == topicNames['D'] or topic == topicNames['Ref']:
			# ipdb.set_trace()
			dataLists['micron'].append([msg.pose.position.x,msg.pose.position.y,msg.pose.position.z,msg.pose.orientation.w,msg.pose.orientation.x,msg.pose.orientation.y,msg.pose.orientation.z,msg.header.frame_id,msg.header.seq])
			timeLists['micron'].append(t)
		elif topic == topicNames['psm_joint']:
			dataLists['psm_joint'].append(list(msg.position))
			timeLists['psm_joint'].append(t)

# Write all the data to a txt file for subsequent processing in matlab (or elsewhere)
f=open('txt_output/'+filename+'.txt','w')
f.write('Version 2\n')
for topicName in dataLists.keys():
	f.write(topicName+'\n')
	for i in range(len(dataLists[topicName])):
		f.write(str(timeLists[topicName][i])+" "+" ".join(str(x) for x in dataLists[topicName][i]) +"\n")
f.close()
