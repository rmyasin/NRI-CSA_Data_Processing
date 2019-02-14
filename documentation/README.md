# First time setup

## Hardware locations
See here for pics from for overall locations of everything: https://docs.google.com/presentation/d/1El2pE4V55CT5LrV1rTUpAKs5SwtxL3iR8cpxC2cSW2E/edit#slide=id.p

VU made a [3d printable stereo holder](https://github.com/rmyasin/NRI-CSA_Data_Processing/blob/master/data/UserStudy3DPrints/eys3dstereoholder.stl)

## Attaching to the PSM
To attach the probe to the robot, run the equivalent codes for your site (in 2 terminal windows): 

```
roslaunch dvrk_nri_robot dvrk_nri_teleop_vu.launch
rostopic echo /dvrk/PSM2/position_cartesian_current
```

Rotate the robot until the rotation orientation is close to:
x: 1.0
y: 0.0
z: 0.0
w: 0.0
You know you're in the wrong (rotated by 180) configuration if the quaternion y is close to 1 instead of x.

The robot should look like this, but there are 2 options, so check that topic:

<img src="https://raw.githubusercontent.com/rmyasin/NRI-CSA_Data_Processing/master/documentation/micron_attach_pose.jpg" alt="attachment_pose" width="250"/>

## Fiducial registration
 * Because we now have a base plate that attaches directly to the force sensor to lock the organ in place, you only need to register the organ one time at each site, and the appropriate registration .txt files will be created. The robot *and* the micron tracker need to be connected for this registration to work properly.
 * Follow the fiducial pattern as shown here:
<img src="https://raw.githubusercontent.com/rmyasin/NRI-CSA_Data_Processing/master/documentation/Kidney_holder_user_study.png" alt="reg_pts" width="400"/>

```
roslaunch dvrk_nri_robot dvrk_nri_teleop_vu.launch
rosrun dvrk_nri_robt StudyControl.py
```

Select user '13', and then selection option '7'

You can collect multiple samples at each point

The end effector should be vertical for best results, like this: 

<img src="https://raw.githubusercontent.com/rmyasin/NRI-CSA_Data_Processing/master/documentation/tip_registration.jpg" alt="tip_reg" width="200"/>



## GP Setup
In order for the GP estimation to work properly, make sure to update
cisst-saw-nri/nri/sawNRIModelFW/components/code/mtsGPDataCollector.cpp

The variables vct3 minLimits and vct3 maxLimits need to be changed to match the boundaries of the organ at each site. (around line 100)

# Camera Calibration (dvrk_vision)

There are 2 major camera calibration steps that must be done at each site: stereo camera calibration (that will rectify images for good viewing in the stereo viewer), and stereo to robot calibration.

## Stereo Camera Calibration

* The file "UsefulCommands.txt" in the base folder of [dvrk-vision](https://github.com/gnastacast/dvrk_vision) has some cheat sheets for running camera calibration. You need to run the following (making sure to adjust the size parameters for the number of boxes and square size of the checkerboard pattern you are using):

```sh
roslaunch dvrk_vision justcams.launch
rosrun camera_calibration cameracalibrator.py --size 9x6 --square 0.02286 right:=/stereo/right/image_raw left:=/stereo/left/image_raw left_camera:=/stereo/left right_camera:=/stereo/right --approximate=0.01 --fix-principal-point
```

* You may need to edit just_cams.launch for your own computer. Test the image capture by running rqt_image_view and making sure both cameras are working. I created one for vanderbilt called "just_cams_VU.launch" to make the necessary parameter adjustments.
* After taking in enough data that all the bars on the right of the calibration screen are green, press "calibrate" and "save"
* Extract the results to a path like ~/catkin_ws/src/dvrk_vision/defaults/eAP870_calibration_left_1600x600.yaml and ~/catkin_ws/src/dvrk_vision/defaults/eAP870_calibration_right_1600x600.yaml for the left and right cameras.

## Stereo to Robot Registration
Run to corresponding code for your institution of:

```sh
roslaunch dvrk_vision dvrk_registration_vu.launch
```

This should move the robot to a series of positions and segment a colored dot on the tip of the probe. You can put some nail polish on it (which will come off) or put a piece of colored tape on the tip. Make sure to start the code with the red point oriented to be facing towards the cameras so it can be easily segmented.

In order to change the points the robot moves to, /catkin_ws/src/dvrk_vision/defaults/registration_params_jhu.yaml has the point list


# Details of Getting to setup
## Tip Calibration Procedure (optional)
There is an option for unique tip_calibration.yaml files, but if you glue the markers properly, we should be able to use the same for each site.

If you need to print the stl, the [probe design](https://github.com/vu-arma-dev/cpd-registration/tree/master/userstudy_data/UserStudy3DPrints) is also available. The probe tip is available on [mcmaster](https://www.mcmaster.com/9614K24)

The launch file to collect micron data will need to be edited/copied for each site because of differences in the micron setup. VU needs to run the micron with UDP transfer, JHU needs to run on a separate computer, CMU is just runing the saw component on the same computer. Run this, changing the foldername for your computer:

```
roslaunch dvrk_nri_robot micron.launch foldername:=/home/arma/catkin_ws/data/micron/
```

With this running, perform tip calibration of each face of the probe and also show the micron frames showing adjacent faces in the same image (AB, BC, CD, DA). Now, to process the bag, run:

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

## Json Updates for New Probe
We apply a constant tip offset to the end of the gripper to make the kinematics match with the tip of the actual probe. The default gripper distance is 10.2 mm, which is the distance from the center of rotation of the jaws to the tip of the large needle driver. The default is found in psm-large-needle-driver.json.json

We need to edit that to create psm-large-needle-driver_micron_probe.json which has an offset to match probe_micron_v5 which has an additional offset of 11 mm to the center of the probe (for a total of 22.2 mm). 

For future calculations, remember that the spherical probe itself has a radius of 3.2 mm, and that the end-effector location should be the center of the sphere.
 
If we think it's necessary, this could be calibrated by, after performing pivot calibration of the probe, rotating the robot's end-effector about the jaw and finding the distance from that axis of the measured tip points.

The json files for the kinematics are located at:
catkin_ws/src/cisst-saw-nri/sawIntuitiveResearchKit/share
