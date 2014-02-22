##############################################################################
#                                                                            #
# Author: Tyler Janzen                                                       #
# Date: Feb. 22, 2014                                                        #
#                                                                            #
# This script will copy the CM-11.0 update-binary to your flashable zip.     #
# It also extracts and modifies the build.pro properties for ro.build.type,  #
# ro.product.locale.region and ro.kernel.android.checkjni to be user, CA and #
# 0 (or off) respectively                                                    #
#                                                                            #
##############################################################################

lcyan='\e[1;32m'
lred='\e[1;31m'
NC='\e[0m'

WF=$(pwd -L)
MT="$WF/buildtools/META-INF"
OF="$WF/out/target/product/celoxhd"
TF="$OF/tmp"
ZIP=''

echo " "
echo " "
echo -e "${lcyan}********************************************************************${NC}"
echo -e "${lcyan}*                       FIXING FLASHABLE ZIP                       *${NC}"
echo -e "${lcyan}********************************************************************${NC}"
echo " "
echo " "

for file in $OF/*;
do
    fileName=$(basename "$file");
    
    if [[ "$fileName" =~ ^cm-10\.2.* ]] && [[ "$fileName" =~ .*celoxhd\.zip$ ]];
    then
        ZIP="$file"
    fi
done

if [ ! "$ZIP" == "" ];
then
    if [ ! -f "$TF" ];
    then
        echo -e "${lcyan}Making tmp dirs${NC}"
        mkdir -p "$TF"
        mkdir "$TF/system"
    fi

    echo -e "${lcyan}Copying CM-11 META-INF to OUT/tmp${NC}"
    cp -R "$MT" "$TF"
    
    if [ ! $? -eq 0 ];
    then
        echo -e "${lred}Copying META-INF failed"
    fi
    
    echo -e "${lcyan}Extracting build.prop to OUT/tmp/system{$NC}"
    7z e -o"$TF/system" "$ZIP" "system/build.prop"
    echo " "

    echo -e "${lcyan}Replacing build.prop values for ro.build.type, ro.product.locale.region and ro.kernel.android.checkjni${NC}"
    sed -i "s/ro\.build\.type=eng/ro\.build\.type=user/g" "$TF/system/build.prop"
    sed -i "s/ro\.product\.locale\.region=US/ro\.product\.locale\.region=CA/g" "$TF/system/build.prop"
    sed -i "s/ro\.kernel\.android\.checkjni=1/ro\.kernel\.android\.checkjni=0/g" "$TF/system/build.prop"

    echo -e "${lcyan}Updating META-INF${NC}"
    7z a "$ZIP" "$TF/META-INF"
    echo " "
    
    echo -e "${lcyan}Updating system${NC}"
    7z a "$ZIP" "$TF/system"
    echo " "

    echo -e "${lcyan}Removing OUT/tmp${NC}"
    rm -r "$TF"
    
    echo -e "${lcyan}Zip updated successfully${NC}"
    echo " "
fi

