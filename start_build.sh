lcyan='\e[1;32m'
lred='\e[1;31m'
NC='\e[0m'

SCRIPTVERSION='1.0'

### FUNCTIONS ###

function banner(){
    echo " "
    echo " "
    echo -e "${lcyan}***************************************************${NC}"
    echo "                                                   "
    echo -e "               ${lcyan}CM-11.0 BUILD SCRIPT${NC}                "
    echo -e "                    ${lcyan}Version $SCRIPTVERSION${NC}         "
    echo -e "                ${lcyan}for the SGH-I757M${NC}                  "
    echo "                                                   "
    echo -e "${lcyan}***************************************************${NC}"
}

### END FUNCTIONS ###

CLOBBER='N'
SYNC='N'
PREBUILTS='N'
if [ $# -eq 1 ];
then
    case $1 in
        '-c')
            CLOBBER='Y'
        ;;
        '-s')
            SYNC='Y'
        ;;
        '-p')
            PREBUILTS='Y'
        ;;
        '-cs' | '-sc')
            CLOBBER='Y'
            SYNC='Y'
        ;;
        '-cp' | '-pc')
            CLOBBER='Y'
            PREBUILTS='Y'
        ;;
        '-sp' | '-ps')
            SYNC='Y'
            PREBUILTS='Y'
        ;;
        '-csp' | '-cps' | '-scp' | '-spc' | '-pcs' | '-psc')
            CLOBBER='Y'
            SYNC='Y'
            PREBUILTS='Y'
        ;;
        '-h' | '--help')
            banner
            echo -e "${lcyan}                       USAGE                       ${NC}"
            echo -e "${lcyan}***************************************************${NC}"
            echo " "
            echo "./start_build.sh [OPTION(s)]"
            echo " "
            echo "OPTIONS"
            echo "    -c     Clobber the out directory before building"
            echo "    -s     Sync repos before building"
            echo "    -p     Sync pre-builts before building"
            echo " "
            echo -e "${lcyan}***************************************************${NC}"
            echo " "
            echo " "
            
            exit 0
        ;;
        *)
            echo " "
            echo " "
            echo "Invalid parameter: $1"
            echo " "
            echo " "
            
            exit 1
        ;;
    esac
elif [ $# -gt 0 ];
then
    echo " "
    echo " "
    echo "Too many parameters..."
    echo " "
    echo " "
    
    exit 1
fi

banner
echo " "
echo " "

. build/envsetup.sh
lunch cm_celoxhd-eng

if [ $CLOBBER == "Y" ];
then
    echo -e "${lcyan}Clobbering out directory...${NC}"
    echo " "
    echo " "
    make clobber
    echo " "
    echo " "
    echo -e "${lcyan}Out directory clobbered!${NC}"
    echo " "
    echo " "
fi

if [ $SYNC == "Y" ];
then
    echo -e "${lcyan}Syncing repositories before build...${NC}"
    echo " "
    echo " "
    repo sync -j5
    echo " "
    echo " "
    echo -e "${lcyan}Syncing repositories completed!${NC}"
    echo " "
    echo " "
fi

if [ $PREBUILTS == "Y" ];
then
    echo -e "${lcyan}Syncing CM pre-builts...${NC}"
    echo " "
    echo " "
    vendor/cm/get-prebuilts
    echo " "
    echo " "
    echo -e "${lcyan}Finished syncing CM pre-builts!${NC}"
    echo " "
    echo " "
fi


DATE_START=$(date +%m/%d/%Y-%H:%M)
DATE_NOW=$(date +%Y%m%d-%H%M)
start_time=$(date +%s)

echo -e "${lcyan}Starting build...${NC}"
echo -e "${lcyan}Build started at${NC} $DATE_START"
echo -e "${lcyan}Build errors being recorded to: ${NC}logs/CM110BuildError-$DATE_NOW.log"
echo " "
echo " "

if [ ! -d "./logs" ];
then
    mkdir -p ./logs 2> /dev/null
fi

make bacon -j24 2> logs/CM110BuildErrors-$DATE_NOW.log

BUILDSTATUS=$?
finish_time=$(date +%s)
elapsed=$((finish_time - start_time))
hours=$((elapsed / 3600))
minutes=$(((elapsed - (hours * 3600)) / 60))
seconds=$((elapsed - ((minutes * 60) + (hours *3600))))
DATE_END=$(date +%m/%d/%Y-%H:%M)

if [ $BUILDSTATUS -gt 0 ];
then
    echo " "
    echo " "
    echo -e "${lred}BUILD FAILED!${NC}"
fi

echo " "
echo " "
echo -e "${lcyan}Build started at${NC} $DATE_START"
echo -e "${lcyan}Build finished at${NC} $DATE_END"
echo -e "${lcyan}and took${NC} $hours ${lcyan}hours ${NC} $minutes ${lcyan}minutes and${NC} $seconds seconds."
echo " "
echo " "
