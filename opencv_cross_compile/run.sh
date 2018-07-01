#!/usr/bin/env bash
 
chmod +x scripts/*.sh
 
scripts/downloadPackages.sh
scripts/importFiles.sh
scripts/crossCompile.sh
scripts/sendOpenCV.sh
 
echo "----- To complete installation, log into the target board and execute the command: "
echo "sudo rsync -av installation/ /usr/local"
