# NRI-CSA_Data_Processing

This is a repository for processing the data created for the [NRI-CSA project](http://nri-csa.vuse.vanderbilt.edu/joomla/) user study on assistive features during robot manipulation.

There are different data processing pipelines for the various sections of the project:

# Pre-Processing for System Calibration

## Tip Calibration Procedure
Help with probe construction/marker printing is available in the documentation folder of this repo. If you need to print the stl, the [probe design](https://github.com/vu-arma-dev/cpd-registration/tree/master/userstudy_data/UserStudy3DPrints) is also available.

The launch file to collect micron data will need to be edited/copied for each site because of differences in the micron setup. VU needs to run the micron with UDP transfer, JHU needs to run on a separate computer, hopefully CMU can just run the saw component on the same computer. Run this, changing the foldername for your computer:

```
roslaunch dvrk_nri_robot micron.launch foldername:=/home/arma/catkin_ws/data/micron/
```

Then perform tip calibration of each face of the probe and also show the micron frames showing adjacent faces in the same image (AB, BC, CD, DA). Now, to process the bag, run:

```
rosrun nri_csa_processing main_process_experiment.py /home/arma/catkin_ws/data/micron/micron_2018-12-02-10-56-10_0.bag -o VUTipDec2TEST -f /home/arma/catkin_ws/src/processing.git/scripts/txt_output/
```

The first argument is the bag you just created. The 'o' and 'f' options give the output txt filename and foldername, respectively. The default folder is the data folder of this repository.

To actually get the pivot calibration, in MATLAB run (with the above folder and file names)

```
pivot_calibration_micron(filefolder, fileName)
```

This is also located within the script "Main_Calibrate_User_Study.m", you just need to update the folders/files correctly. A slightly different method is shown in "Main_Calibrate_JHU.m"

At the end, the file tip_calibration.yaml should be created. That will be saved in the "config" folder.

TODO: add an option in launch files for MicronTracking.py so that each site can have a unique tip_calibration.yaml file

## Attaching to the PSM
To attach the probe to the robot, run (in 2 terminal windows): 

```
roslaunch dvrk_nri_robot dvrk_nri_teleop_vu.launch
rostopic echo /dvrk/PSM2/position_cartesian_current
```

Make sure the rotation orientation is close to when attaching
x: 0.7071
y: 0.7071
z: 0.0
w: 0.0
 You know you're in the wrong (rotated by 180) configuration if the quaternion y is negative.

 The robot should look like this, but there are 2 options, so check that topic:

<img src="https://raw.githubusercontent.com/rmyasin/NRI-CSA_Data_Processing/master/documentation/micron_attach_pose.jpg" alt="attachment_pose" width="200"/>

## Json Updates for New Probe
We apply a constant tip offset to the end of the gripper to make the kinematics match with the tip of the actual probe. The default gripper distance is 10.2 mm, which is the distance from the center of rotation of the jaws to the tip of the large needle driver. The default is found in psm-large-needle-driver.json.json

We need to edit that to create psm-large-needle-driver_micron_probe.json which has an offset to match probe_micron_v5 which has an additional offset of 11 mm to the center of the probe (for a total of 22.2 mm). 

For future calculations, remember that the spherical probe itself has a radius of 3.2 mm, and that the end-effector location should be the center of the sphere.
 
If we think it's necessary, this could be calibrated by, after performing pivot calibration of the probe, rotating the robot's end-effector about the jaw and finding the distance from that axis of the measured tip points.

The json files for the kinematics are located at:
catkin_ws/src/cisst-saw-nri/sawIntuitiveResearchKit/share

## GP Setup
In order for the GP estimation to work properly, make sure to update
cisst-saw-nri/nri/sawNRIModelFW/components/code/mtsGPComponent.cpp

The variables vct3 minLimits and vct3 maxLimits need to be changed to match the boundaries of the organ at each site. (~line 74) 

# Processing Data Collected During User Study
1) Save data in a rosbag (preferably by using rosrun dvrk_nri_robot StudyControl.py)
2) (optional) Change the GP parameters in GP.cpp located in nri/sawNRIModelFW/components/code
3) (if optional) run catkin build
4) rosbag play name_of_saved_bag
    1) -r # will speed up the playback by # times
    1) -s # will start # seconds into the bag
5) rosrun csa_ros_applications gp_online -p PSM2
5) run a visualizer (eg [Preetham's Matlab script](https://git.lcsr.jhu.edu/nri-csa/nri/blob/devel/sawNRIModelFW/matlab/ral_demo_online.m)  )

# Processing Continuous Palpation Data
If you take data from the [continuous palpation]() repository, ... TODO


