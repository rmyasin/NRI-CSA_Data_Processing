# NRI-CSA_Data_Processing

This is a repository for processing the data created for the [NRI-CSA project](http://nri-csa.vuse.vanderbilt.edu/joomla/) user study on assistive features during robot manipulation.

The [documentation folder](https://github.com/rmyasin/NRI-CSA_Data_Processing/tree/master/documentation) has information on hardware/first time setup.

# Running the User Study
The main documentation for keeping the code up to date is in (the nri-csa gitlab repo)(https://git.lcsr.jhu.edu/nri-csa/cisst-saw-nri/wikis/user-study-experiment). However, we have moved the documentation for actually running the user study here.


## Startup

* Source appropriate catkin workspace (needs to be using Preetham's dvrk-nri code, not base cisst-saw)

   ```sh
   source ~/catkin_ws/devel/setup.bash
   ```
* run the robot by calling (with appropriate launch file for your site)

   ```sh
   roslaunch dvrk_nri_robot dvrk_nri_teleop_vu.launch
   # To select a particular organ, run the following - letters and numbers are both ok
   roslaunch dvrk_nri_robot dvrk_nri_teleop_vu.launch organ_letter:=A
   roslaunch dvrk_nri_robot dvrk_nri_teleop_vu.launch organ_letter:=22

   # On a different terminal and source as above
   roslaunch dvrk_vision user_study.launch

   # On a third terminal and source as above
   rosrun dvrk_nri_robot StudyControl.py
   ```

* Follow on-screen instructions to switch modes in the StudyControl terminal. The console will fill up with messages about rosbags (I can't figure out how to turn those off) but you can input "1" to re-display the different options to change modes


# Data Processing
## Rosbag processing
Step one is to move from rosbags to txt files so that you can open up the data in matlab without waiting an hour to open the bag (literally I had to wait multiple minutes just to open the bags in matlab)
  ```sh
  cd ~/catkin_ws/data/user1
  rosrun nri_csa_processing main_process_experiment.py Palpation_VisualForce_yyyy-mm-dd-hh-mm-ss_0.bag
  ```
  Do the same with all the bags in the folder (except the video bags, I don't know what we're planning on doing with them)

## Rosbag errors
You may have a problem wherein the bag recording did not exit properly and even though recording is done, the bag is marked ".active". Run the following commands on your bag (replacing the reindex and fix commands with your desired bag to fix).
  ```rosbag reindex Palpation_VisualForce_20_2019-04-04-16-03-49_2.bag.active
   rosbag fix Palpation_VisualForce_20_2019-04-04-16-03-49_2.bag.active user22/Palpation_VisualForce_20_2019-04-04-16-03-49_2.bag
   ```

## MATLAB processing
Now that we have .txt files...
TODO: fill in details, make overview scripts of data results

##Processing Continuous Palpation Data
If you take data from the [continuous palpation](https://github.com/vu-arma-dev/continuous_palpation) repository, 
... TODO: fill in details


## Processing GP Data Collected During User Study
1) Save data in a rosbag (preferably by using rosrun dvrk_nri_robot StudyControl.py)
2) (optional) Change the GP parameters in GP.cpp located in nri/sawNRIModelFW/components/code
3) (if optional) run catkin build
4) rosbag play name_of_saved_bag
    1) -r # will speed up the playback by # times
    1) -s # will start # seconds into the bag
5) rosrun csa_ros_applications gp_online -p PSM2
5) run a visualizer (eg [Preetham's Matlab script](https://git.lcsr.jhu.edu/nri-csa/nri/blob/devel/sawNRIModelFW/matlab/ral_demo_online.m)  )
