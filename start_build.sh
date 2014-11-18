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
    echo -e "               ${lcyan}CM-12.0 BUILD SCRIPT${NC}                "
    echo -e "                    ${lcyan}Version $SCRIPTVERSION${NC}         "
    echo -e "                ${lcyan}for the SGH-I757M${NC}                  "
    echo "                                                   "
    echo -e "${lcyan}***************************************************${NC}"
}

### END FUNCTIONS ###

### INITIALIZE VARIABLES ###

CLOBBER='N'
SYNC='N'
PREBUILTS='N'
THREADS=$(grep 'processor' /proc/cpuinfo | wc -l)

### END INITIALIZE VARIABLES ###

if [ $# -eq 1 ] || [ $# -eq 2 ];
then
    if ! [ ${1//[0-9]/} == "-j" ];
    then
        OPTIONSARG=$1
    elif [ $# -eq 2 ] && ! [ ${2//[0-9]/} == "-j" ];
    then
        OPTIONSARG=$2
    else
        OPTIONSARG='null'
    fi
    
    if ! [ $OPTIONSARG == "null" ];
    then
        case $OPTIONSARG in
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
                echo -e "                       USAGE                       "
                echo -e "${lcyan}***************************************************${NC}"
                echo " "
                echo "./start_build.sh [OPTION(s)]"
                echo " "
                echo "OPTIONS"
                echo "    -c     Clobber the out directory before building"
                echo "    -s     Sync repos before building"
                echo "    -p     Sync pre-builts before building"
                echo " "
                echo "    -j     Number of threads to use for build"
                echo "           MUST BE FOLLOWED BY A NUMBER REPRESENTING"
                echo "           THE NUMBER OF CORES YOUR SYSTEM HAS."
                echo "           IF YOU OMIT THIS OPTION, THE SCRIPT WILL"
                echo "           DETECT THE NUMBER OF CORES AUTOMATICALLY."
                echo " "
                echo "           THIS OPTION MUST BE ENTERED AS IT'S OWN"
                echo "           ARGUMENT SEPARATE FROM THE OTHER ARGUMENTS."
                echo " "
                echo "           Example: ./start_build.sh -j4"
                echo "                    ./start_build.sh -j4 -csp"
                echo "                    ./start_build.sh -csp -j4"
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
    fi
    
    if [ ${1//[0-9]/} == "-j" ];
    then
        THREADS=${1//-j/}
    elif [ $# -eq 2 ] && [ ${2//[0-9]/} == "-j" ];
    then
        THREADS=${2//-j/}
    fi
elif [ $# -gt 2 ];
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
echo -e "${lcyan}Build using${NC} $THREADS ${lcyan}threads${NC}"
echo -e "${lcyan}Build errors being recorded to: ${NC}logs/CM110BuildError-$DATE_NOW.log"
echo " "
echo " "

if [ ! -d "./logs" ];
then
    mkdir -p ./logs 2> /dev/null
fi

mka bacon -j$THREADS 2> logs/CM120BuildErrors-$DATE_NOW.log

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
