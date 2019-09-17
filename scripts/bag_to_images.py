#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright 2016 Massachusetts Institute of Technology

"""Extract images from a rosbag.
"""
#https://gist.github.com/wngreene/835cda68ddd9c5416defce876a4d7dd9

import os
import argparse

import cv2
import re

import rosbag
from sensor_msgs.msg import Image
from cv_bridge import CvBridge
from main_process_experiment import getMatchingRosBags
import ipdb

def main():
    """Extract a folder of images from a rosbag.
    """
    parser = argparse.ArgumentParser(description="Extract images from a ROS bag.")
    parser.add_argument("bag_file", help="Input ROS bag.")
    parser.add_argument("output_dir", help="Output directory.")
    parser.add_argument("image_topic", help="Image topic.")
    parser.add_argument("-v","--video",help="Boolean: make a video",type=int)

    args = parser.parse_args()


    print "Extract images from %s on topic %s into %s" % (args.bag_file,
                                                          args.image_topic, args.output_dir)

    bridge = CvBridge()
    fourcc = cv2.VideoWriter_fourcc(*'XVID')


    inputLocation=args.bag_file
    if not inputLocation.endswith('bag'):
        fileList=os.listdir(inputLocation)
        regexbag=re.compile("^Video_.*_0.bag$")
        findBagList=filter(regexbag.match,fileList)
    else:
        findBagList = [inputLocation]

    for findBag in findBagList:
        folderPath=os.path.abspath(os.path.join(findBag,'..'))
        bagList=getMatchingRosBags(folderPath,findBag)
        count = 0
        if args.video!=0:
            videoOut = cv2.VideoWriter(os.path.abspath(os.path.join(args.output_dir,findBag[0:-4]+'.avi')),fourcc, 4.0, (800,600))    
        
        for bagName in bagList:
            bag = rosbag.Bag(bagName, "r")
            for topic, msg, t in bag.read_messages(topics=[args.image_topic]):
                if args.video!=0:
                    cv_img = bridge.imgmsg_to_cv2(msg, desired_encoding="bgr8")
                    videoOut.write(cv_img)
                else:
                    cv_img = bridge.imgmsg_to_cv2(msg, desired_encoding="passthrough")
                    cv2.imwrite(os.path.join(args.output_dir, "frame%06i.png" % count), cv_img)
                    print "Created image %i" % count            
                count += 1

            bag.close()
        if args.video!=0:
            videoOut.release()
            print "Wrote %i images to video" % count
    return

if __name__ == '__main__':
    main()