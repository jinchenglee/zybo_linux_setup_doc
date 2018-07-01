#!/usr/bin/env bash
source scripts/config
 
# Create folder structure
echo "----- Creating python folder structure"
mkdir opencv/python
mkdir opencv/python/lib
mkdir opencv/python/include
mkdir opencv/python/include/python2.7
mkdir opencv/python/include/python3.5m
cd opencv/python
 
echo "----- Retrieving python files"
if [ -n "${PASSWORD}" ]; then
    # Python config
    sshpass -p ${PASSWORD} scp ${NAME}@${ADDRESS}:/usr/include/${ARCHITECTURE}/python2.7/pyconfig.h include/python2.7/
    sshpass -p ${PASSWORD} scp ${NAME}@${ADDRESS}:/usr/include/${ARCHITECTURE}/python3.5m/pyconfig.h include/python3.5m/
    # Python libraries
    sshpass -p ${PASSWORD} scp ${NAME}@${ADDRESS}:/usr/lib/${ARCHITECTURE}/libpython*.so lib
else
    # Python config
    scp ${NAME}@${ADDRESS}:/usr/include/${ARCHITECTURE}/python2.7/pyconfig.h include/python2.7/
    scp ${NAME}@${ADDRESS}:/usr/include/${ARCHITECTURE}/python3.5m/pyconfig.h include/python3.5m/
    # Python libraries
    scp ${NAME}@${ADDRESS}:/usr/lib/${ARCHITECTURE}/libpython*.so lib
fi
 
# Copy Python config files
echo "----- Copying imported config files"
sudo mkdir /usr/include/${ARCHITECTURE}
sudo mkdir /usr/include/${ARCHITECTURE}/python2.7
sudo mkdir /usr/include/${ARCHITECTURE}/python3.5m
sudo cp include/python2.7/pyconfig.h /usr/include/${ARCHITECTURE}/python2.7
sudo cp include/python3.5m/pyconfig.h /usr/include/${ARCHITECTURE}/python3.5m
