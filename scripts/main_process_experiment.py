#!/usr/bin/env python

# This file runs through a rosbag and writes selected topics to a txt file
# The main utility of this is in converting rosbags with many topics
# that can be slow to process in matlab to a shorter, more succinct representation
# with only the needed data

import rospy
import sys
from std_msgs.msg import Float32
from std_msgs.msg import Bool
from std_msgs.msg import Empty
from sensor_msgs.msg import JointState
from sensor_msgs.msg import Joy
from geometry_msgs.msg import Quaternion
from geometry_msgs.msg import PoseStamped
from cisst_msgs.msg import prmCartesianImpedanceGains

import os
import rospkg
import shutil
import re
import rosbag
import numpy as np
import argparse
import copy
import ipdb

def locateInList(inlist,element):
  for i in range(len(inlist)):
    if inlist[i]==element:
      return i


def getMatchingRosBags(folder,bagName):
  bagList=[bagName]

  dateEnd=bagName.rfind('_') 
  dateStart=dateEnd-19
  matchName=bagName[0:dateStart] # Find beginning string of the bag
  regexbag=re.compile('^'+matchName) # Find all bags with the same string

  fileList=os.listdir(folder) 
  newList=filter(regexbag.match,fileList)
  bagNumbers=[temp[-5] for temp in newList]

  if dateStart>=0:
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

def main():  
  parser = argparse.ArgumentParser()
  parser.add_argument("bag",help="bag input file name",type=str)
  parser.add_argument("-o","--output",help="output file name",type=str)
  parser.add_argument("-f","--folder",help="output folder path",type=str)
  args=parser.parse_args()
  
  findBag=args.bag#eg 'Palpation_DirectForce_2018-10-02-11-27-20_0.bag'
  folderPath=os.path.abspath(os.path.join(findBag,'..'))


  if args.folder:
    outFolderPath=args.folder
  else:
    outFolderPath = folderPath

  if args.output:
    filename = args.output
  else:
    filename= findBag[:-4]
  # Find all bags in a sequence of auto-saved bags
  bagList=getMatchingRosBags(folderPath,findBag)

  # Set up lists of data to save and corresponding topics
  dataLists = {'force':[],'psm_cur':[],'mtm_cur':[],'camera':[],'cam_minus':[],'cam_plus':[],'clutch':[],'coag':[],'psm_des':[],'micronTip':[],'micron':[],'micronValid':[],'psm_joint':[],'poi_points':[],'poi_clear':[],'display_points':[],'artery_status':[],'text':[]}
  timeLists = copy.deepcopy(dataLists)
  topicNames= { 'force':  '/dvrk/PSM2/wrench',
          'psm_cur':  '/dvrk/PSM2/position_cartesian_current',
          'mtm_cur':  '/dvrk/MTMR/position_cartesian_current',
          'camera' :  '/dvrk/footpedals/camera',
          'cam_minus' :  '/dvrk/footpedals/cam_minus',
          'cam_plus' :  '/dvrk/footpedals/cam_plus',
          'clutch' :  '/dvrk/footpedals/clutch',
          'coag' :  '/dvrk/footpedals/coag',
          'psm_des':  '/dvrk/PSM2/position_cartesian_desired',
          'micronTip' : '/MicronTipPose',
          'micronValid':['/micron/PROBE_A/measured_cp_valid','/micron/PROBE_B/measured_cp_valid','/micron/PROBE_C/measured_cp_valid','/micron/PROBE_D/measured_cp_valid'],
          'psm_joint':'/dvrk/PSM2/state_joint_current',
          'A' :   ['/A','/micron/PROBE_A/measured_cp',],
          'B' :   ['/B','/micron/PROBE_B/measured_cp',],
          'C' :   ['/C','/micron/PROBE_C/measured_cp',],
          'D' :   ['/D','/micron/PROBE_D/measured_cp',],
          'Ref' :   ['/Ref','/micron/Ref',],
          'poi_points': '/dvrk_vision/user_POI',
          'poi_clear': '/dvrk_vision/clear_POI',
          'display_points': '/control/Vision_Point_List',
          'artery_status': '/control/arteryStatus',
          'text':'/control/textDisplay',
        }
  
  topicList=list()
  for element in topicNames.values():
    if type(element)==list:
      for item in element:
        topicList.append(item)
    else:
      topicList.append(element)

  # Fill lists of each data type
  for bagName in bagList:
    bag = rosbag.Bag(os.path.join(folderPath,bagName))
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
      elif topic == topicNames['cam_minus']:
        dataLists['cam_minus'].append(msg.buttons)
        timeLists['cam_minus'].append(t)
      elif topic == topicNames['cam_plus']:
        dataLists['cam_plus'].append(msg.buttons)
        timeLists['cam_plus'].append(t)
      elif topic == topicNames['clutch']:
        dataLists['clutch'].append(msg.buttons)
        timeLists['clutch'].append(t)
      elif topic == topicNames['coag']:
        dataLists['coag'].append(msg.buttons)
        timeLists['coag'].append(t)
      elif topic == topicNames['psm_des']:
        dataLists['psm_des'].append([msg.pose.position.x*1000,msg.pose.position.y*1000,msg.pose.position.z*1000,msg.pose.orientation.w,msg.pose.orientation.x,msg.pose.orientation.y,msg.pose.orientation.z])
        timeLists['psm_des'].append(t)
      elif topic == topicNames['micronTip']:
        dataLists['micronTip'].append([msg.pose.position.x,msg.pose.position.y,msg.pose.position.z,msg.pose.orientation.w,msg.pose.orientation.x,msg.pose.orientation.y,msg.pose.orientation.z,msg.header.seq])
        timeLists['micronTip'].append(t)
      elif topic in topicNames['A'] or topic in topicNames['B'] or topic in topicNames['C'] or topic in topicNames['D'] or topic in topicNames['Ref']:
        dataLists['micron'].append([msg.pose.position.x,msg.pose.position.y,msg.pose.position.z,msg.pose.orientation.w,msg.pose.orientation.x,msg.pose.orientation.y,msg.pose.orientation.z,msg.header.frame_id,msg.header.seq])
        timeLists['micron'].append(t)
      elif topic in topicNames['micronValid']:
        dataLists['micronValid'].append([topic, msg.data])
        timeLists['micronValid'].append(t.to_nsec())
      elif topic == topicNames['psm_joint']:
        dataLists['psm_joint'].append(list(msg.position))
        timeLists['psm_joint'].append(t)
      elif topic== topicNames['poi_points']:
        dataLists['poi_points'].append([msg.x,msg.y,msg.z])
        timeLists['poi_points'].append(t)
      elif topic== topicNames['poi_clear']:
        dataLists['poi_clear'].append([1])
        timeLists['poi_clear'].append(t)
      elif topic== topicNames['display_points']:
        # ipdb.set_trace()
        tempList=list()
        for pose in msg.poses:
          tempList.append(pose.position.x)
          tempList.append(pose.position.y)
          tempList.append(pose.position.z)
        dataLists['display_points'].append(tempList)
        timeLists['display_points'].append(t)
      elif topic==topicNames['artery_status']:
        dataLists['artery_status'].append([msg.data])
        timeLists['artery_status'].append(t)
      elif topic==topicNames['text']:
        dataLists['text'].append(msg.data.__repr__())
        timeLists['text'].append(t)

  # Write all the data to a txt file for subsequent processing in matlab (or elsewhere)
  f=open(os.path.join(outFolderPath,filename+'.txt'),'w')
  f.write('Version 3\n')
  for topicName in dataLists.keys():
    f.write(topicName+'\n')
    for i in range(len(dataLists[topicName])):
      if type(dataLists[topicName][i])==str:
        f.write(str(timeLists[topicName][i])+" "+dataLists[topicName][i] +"\n")
      else:
        f.write(str(timeLists[topicName][i])+" "+" ".join(str(x) for x in dataLists[topicName][i]) +"\n")
  f.close()

if __name__ == '__main__':
  main()