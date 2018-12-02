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
**TODO: UPDATE LOCAL JSON FILES FOR DVRK KINEMATICS**

# Processing Data Collected During User Study
TODO

# Processing Continuous Palpation Data
If you take data from the [continuous palpation]() repository, ... TODO


