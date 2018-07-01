The steps/scripts come from http://www.alvaroferran.com/blog/cross-compiling-opencv-for-embedded-linux

The full procedure would then look something like this:
```
1. Install any missing packages needed and download OpenCV
2. Copy the required files from the target board
3. Cross-compile OpenCV
4. Send the compiled library to the target board
```
Each stage is completed by a different script, which takes care of intermediate steps such as creating directories as well. There is also a configuration file where the board’s username, IP address and type are specified, and optionally the password too. The board type is arm-linux-gnueabihf for an armhf architecture and x86_64-linux-gnu for x86_64, there will probably be a folder under /usr/include/ with the correct name for other architectures. If the password field is filled, that is what will be used to transfer the files, if left empty the user must manually enter it each time.

Run.sh script:
```
#!/usr/bin/env bash
 
chmod +x scripts/*.sh
 
scripts/downloadPackages.sh
scripts/importFiles.sh
scripts/crossCompile.sh
scripts/sendOpenCV.sh
 
echo "----- To complete installation, log into the target board and execute the command: "
echo "sudo rsync -av installation/ /usr/local"
```
Once the installation folder containing the compiled library has been transferred to the board, log into it and execute
```
sudo rsync -av installation/ /usr/local
```
to copy the different files to the corresponding places.


## Issues

### GLIBXX related
If when trying to import cv2 there is an error about not finding the corresponding GLIBXX version in the board as the one used to compile, try upgrading g++ to the appropiate version. For example, for GLIBCXX_3.4.22 execute
```
sudo apt upgrade g++-6
```
The complete process will vary depending on processing speed, Internet connection and packages already present, but in my case took just under 30 minutes from launching the script to receiving the folder in the board.

### libopencv_core.so.* cannot open shared object file

The error occurs when 'import cv2' in python or similar C++ code usage.

After the rsync operations on target board, do below to "populate" the installed libraries:

```
sudo ldconfig -v
```
