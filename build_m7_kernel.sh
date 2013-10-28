#!/bin/bash

# Path to build your kernel
  k=~/kernel/android_kernel_htc_m7
# Directory for the any kernel updater
  t=$k/packages
# Date to add to zip
  today=$(date +"%m_%d_%Y")

# Setup output directory
       mkdir -p "out/$c"
          cp -R "$t/system" out/$c
          cp -R "$t/META-INF" out/$c
          cp -R "$t/kernel" out/$c
       mkdir -p "out/$c/system/lib/modules/"

  m=$k/out/$c/system/lib/modules
  z=$c-$today

TOOLCHAIN=/home/forrest/kernel/arm-eabi-4.7/bin/arm-eabi-
export ARCH=arm
export SUBARCH=arm

# make mrproper
make CROSS_COMPILE=$TOOLCHAIN -j`grep 'processor' /proc/cpuinfo | wc -l` mrproper

# remove backup files
find ./ -name '*~' | xargs rm
rm compile.log

# make kernel
make elite_m7_defconfig
make -j`grep 'processor' /proc/cpuinfo | wc -l` CROSS_COMPILE=$TOOLCHAIN >> compile.log 2>&1 || exit -1

# copy modules
find -name '*.ko' -exec cp -av {} ../m7-vzw/system/lib/modules/ \;

# copy kernel image
cp arch/arm/boot/zImage /home/forrest/kernel/android_kernel_htc_m7/out/kernel/kernel

# strip modules
${TOOLCHAIN}strip --strip-unneeded /home/forrest/kernel/android_kernel_htc_m7/out/system/lib/modules/*ko

# create cwm zip
cd 
find ./ -name '*~' | xargs rm
rm *.zip
TIMESTAMP=Elite-`date +%Y%m%d-%T`
zip -r m7-$today.zip *
