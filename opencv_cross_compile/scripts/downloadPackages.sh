#!/usr/bin/env bash
# Install libs
echo "----- Installing necessary packages"
sudo apt-get update
sudo apt-get install -y build-essential sshpass cmake pkg-config libjpeg-dev libtiff5-dev libjasper-dev libpng12-dev libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev libgtk2.0-dev libgtk-3-dev libcanberra-gtk* libatlas-base-dev gfortran python2.7-dev python3-dev
sudo pip install numpy
sudo apt-get install -y gcc-arm-linux-gnueabihf  g++-arm-linux-gnueabihf
 
# Download OpenCV
echo "----- Downloading OpenCV"
git clone https://github.com/opencv/opencv.git
git clone https://github.com/opencv/opencv_contrib.git
