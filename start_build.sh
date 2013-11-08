#!/system/bin/sh

lcyan='\e[1;32m'
NC='\e[0m'

SCRIPTVERSION='1.0'

echo " "
echo " "
echo "***************************************************"
echo "                                                   "
echo "               CM-11.0 BUILD SCRIPT                "
echo "                    Version $SCRIPTVERSION         "
echo "                for the SGH-I757M                  "
echo "                                                   "
echo "***************************************************"
echo " "
echo " "

. build/envsetup.sh
lunch cm_celoxhd-eng

echo " "
echo " "
echo -e "${lcyan}Do you want to clobber the out directory? [Y/N]:${NC}"
read CLOBBER

if [ $CLOBBER == "Y" ];
then
    echo " "
    echo " "
    echo -e "${lcyan}Clobbering out directory...${NC}"
    echo " "
    echo " "
    make clobber
    echo " "
    echo " "
    echo -e "${lcyan}Out directory clobbered!${NC}"
fi


DATE_START=$(date +%m/%d/%Y-%H:%M)
DATE_NOW=$(date +%Y%m%d-%H%M)
start_time=$(date +%s)

echo " "
echo " "
echo -e "${lcyan}Starting build...${NC}"
echo -e "${lcyan}Build started at${NC} $DATE_START"
echo " "
echo " "

make bacon -j24 2> logs/CM110BuildErrors-$DATE_NOW.log

finish_time=$(date +%s)
elapsed=$((finish_time - start_time))
hours=$((elapsed / 3600))
minutes=$(((elapsed - (hours * 3600)) / 60))
seconds=$((elapsed - ((minutes * 60) + (hours *3600))))
DATE_END=$(date +%m/%d/%Y-%H:%M)

echo " "
echo " "
echo -e "${lcyan}Build started at${NC} $DATE_START"
echo -e "${lcyan}Build finished at${NC} $DATE_END"
echo -e "${lcyan}and took${NC} $hours ${lcyan}hours ${NC} $minutes ${lcyan}minutes and${NC} $seconds seconds."
echo " "
echo " "
