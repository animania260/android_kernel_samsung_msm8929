#Samsung Included 4.8 toolchain
#export PATH=~/android/j700p/J700PVPS1AQD1/kernelbuild/arm-eabi-4.8/bin:$PATH
#export ARCH=arm
#export CROSS_COMPILE=~/android/j700p/J700PVPS1AQD1/kernelbuild/arm-eabi-4.8/bin/arm-eabi-

#UberTC 6.0
#export PATH=~/android/toolchains/arm-eabi-6.0/bin:$PATH
#export ARCH=arm
#export CROSS_COMPILE=~/android/toolchains/arm-eabi-6.0/bin/arm-eabi-

#UberTC 5.3
#export PATH=~/android/toolchains/arm-eabi-5.3/bin:$PATH
#export ARCH=arm
#export CROSS_COMPILE=~/android/toolchains/arm-eabi-5.3/bin/arm-eabi-

#UberTC 4.9
export PATH=~/android/toolchains/arm-eabi-4.9/bin:$PATH
export ARCH=arm
export CROSS_COMPILE=~/android/toolchains/arm-eabi-4.9/bin/arm-eabi-

BUILD_KERNEL_DIR=$(pwd)
BUILD_KERNEL_OUT=$(pwd)/out

#use ccache
#export USE_CCACHE=1
#export CCACHE_DIR=~/.ccache
#/usr/bin/ccache -M 50G

#KERNEL_ZIMG=$BUILD_KERNEL_OUT_DIR/arch/arm/boot/zImage
#DTC=$BUILD_KERNEL_DIR/out/scripts/dtc/dtc
#INSTALLED_DTIMAGE_TARGET=$BUILD_KERNEL_OUT_DIR/arch/arm/boot/dt.img
#DTBTOOL=$BUILD_KERNEL_DIR/tools/dtbTool
#BOARD_KERNEL_PAGESIZE=2048

FUNC_BUILD_KERNEL()
(
#clean up
#make -C $(pwd) O=$(pwd)/out clean
#make -C $(pwd) O=$(pwd)/out mrproper
#make -C $(pwd) O=$(pwd)/out distclean
rm -rf out/sohren_install
mkdir -p out/sohren_install
#rm -f out/arch/arm/boot/dts/*.dtb
#rm -f out/arch/arm/boot/dt.img
rm -f twrp-installer/tools/zImage
rm -f twrp-installer/tools/dt.image
rm -f twrp-installer/system/lib/modules/pronto/pronto_wlan.ko

#Compile the kernel
echo "Build kernel"
mkdir $(pwd)/out
make -C $(pwd) O=$(pwd)/out j7ltespr_defconfig
make -C $(pwd) O=$(pwd)/out -j2
cp $(pwd)/out/arch/arm/boot/zImage $(pwd)/arch/arm/boot/zImage

echo "Create dt.img"
tools/dtbTool -o out/arch/arm/boot/dt.img -s 2048 -p out/scripts/dtc/ out/arch/arm/boot/dts/

echo "Kernel and dtimage compilation completed successfully"
echo "........................................................."
echo "..........................................."
echo "............................"
echo ".............."
echo "Compile Modules: modules_install"

make -C $(pwd) O=$(pwd)/out -j2 modules_install INSTALL_MOD_PATH=sohren_install INSTALL_MOD_STRIP=1

# copy zImage, modules, etc to twrp zip path

echo "Copy Modules and create TWRP Zip"
find out/sohren_install/ -name 'wlan.ko' -type f -exec cp '{}' twrp-installer/system/lib/modules/ \;
mv twrp-installer/system/lib/modules/wlan.ko twrp-installer/system/lib/modules/pronto/pronto_wlan.ko
cp out/arch/arm/boot/zImage twrp-installer/tools/
cp out/arch/arm/boot/dt.img twrp-installer/tools/
cd twrp-installer
zip -r ../../releases/akern.zip ./
today=$(date +"-%d%m%Y")
mv ~/android/j700p/anikernel/releases/akern.zip ~/android/j700p/anikernel/releases/akern-$ver$today.zip
echo "COMPLETE....."
)

# MAIN FUNCTION
cp ./build.log ./build.log-bak
rm ./build.log
(
	START_TIME=`date +%s`

	FUNC_BUILD_KERNEL
	#FUNC_RAMDISK_EXTRACT_N_COPY
	#FUNC_MKBOOTIMG

	END_TIME=`date +%s`

	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo "Total compile time is $ELAPSED_TIME seconds"
) 2>&1	 | tee -a ./build.log