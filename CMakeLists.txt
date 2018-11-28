cmake_minimum_required(VERSION 2.8.3)
project(nri_csa_processing)

## Compile as C++11, supported in ROS Kinetic and newer
# add_compile_options(-std=c++11)

## Find catkin macros and libraries
## if COMPONENTS list like find_package(catkin REQUIRED COMPONENTS xyz)
## is used, also find other catkin packages
find_package(catkin REQUIRED COMPONENTS
  roscpp
  std_msgs
  message_generation
  message_runtime
  geometry_msgs
  sensor_msgs
  cisst_msgs
  tf_conversions
  visualization_msgs
  rospy
  rosbag
  tf2
  tf2_ros
)

## Generate added messages and services with any dependencies listed here
 generate_messages(
   DEPENDENCIES
   std_msgs
   geometry_msgs
 )


###################################
## catkin specific configuration ##
###################################
## The catkin_package macro generates cmake config files for your package
## Declare things to be passed to dependent projects
## INCLUDE_DIRS: uncomment this if your package contains header files
## LIBRARIES: libraries you create in this project that dependent projects also need
## CATKIN_DEPENDS: catkin_packages dependent projects also need
## DEPENDS: system dependencies of this project that dependent projects also need
catkin_package(
  INCLUDE_DIRS include
  LIBRARIES ${PROJECT_NAME} 
  CATKIN_DEPENDS roscpp
      roscpp
      std_msgs
      message_generation
      message_runtime
      geometry_msgs
      sensor_msgs
      tf_conversions
      visualization_msgs
      rospy
      rosbag
      tf2
      tf2_ros
)

