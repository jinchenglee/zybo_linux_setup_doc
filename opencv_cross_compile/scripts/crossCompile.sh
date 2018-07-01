#!/usr/bin/env bash
echo "----- Creating cross-compiled build directory structure"
cd opencv
mkdir buildCross
cd buildCross
mkdir installation
 
#make clean
 
echo "----- Setting up compilation"
cmake -D CMAKE_BUILD_TYPE=RELEASE   \
    -D CMAKE_INSTALL_PREFIX=installation \
    -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules   \
    -D CMAKE_TOOLCHAIN_FILE=../platforms/linux/arm-gnueabi.toolchain.cmake ../  \
    -D PYTHON2_INCLUDE_PATH=/usr/include/python2.7  \
    -D PYTHON2_INCLUDE_DIR=../python/include/python2.7    \
    -D PYTHON2_LIBRARY=../python/lib/libpython2.7.so  \
    -D PYTHON2_NUMPY_INCLUDE_DIRS=/usr/local/lib/python2.7/dist-packages/numpy/core/include \
    -D PYTHON3_INCLUDE_PATH=/usr/include/python3.5m \
    -D PYTHON3_INCLUDE_DIR=../python/include/python3.5m    \
    -D PYTHON3_LIBRARY=../python/lib/libpython3.5m.so \
    -D PYTHON3_NUMPY_INCLUDE_DIRS=/usr/lib/python3/dist-packages/numpy/core/include \
    -D BUILD_OPENCV_PYTHON2=OFF  \
    -D BUILD_OPENCV_PYTHON3=ON  \
    -D INSTALL_PYTHON_EXAMPLES=ON  \
    -D BUILD_TESTS=OFF \
    -D BUILD_EXAMPLES=OFF \
    -D ENABLE_NEON=ON  \
    -D ENABLE_VFPV3=ON   \
    -D WITH_TBB=OFF \
    -D BUILD_TBB=OFF ..
 
echo "----- Starting compilation"
#make -j
make
make install
 
cd installation/lib/python3.5/dist-packages/
mv cv2* cv2.so
echo "----- OpenCV correctly built"
