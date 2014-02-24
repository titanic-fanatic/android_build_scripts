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
MT="$WF/buildtools/recovery/META-INF"
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
    
    if [[ "$fileName" =~ ^Slim-celoxhd-4\.4.* ]] && [[ "$fileName" =~ .*\.zip$ ]];
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
    
    echo -e "${lcyan}Creating directory ${NC}OUT/tmp/META-INF/com/google/android"
    mkdir -p "$TF/META-INF/com/google/android" 2> /dev/null
    echo " "
    
    echo -e "${lcyan}Extracting ${NC}build.prop${lcyan} to ${NC}OUT/tmp/system"
    7z e -o"$TF/system" "$ZIP" "system/build.prop"  
    echo " "
    
    echo -e "${lcyan}Extracting ${NC}updater-script${lcyan} to ${NC}OUT/tmp/META-INF/com/google/android"
    7z e -o"$TF/META-INF/com/google/android" "$ZIP" "META-INF/com/google/android/updater-script"
    echo " "
    
    echo -e "${lcyan}Creating temporary ${NC}updater-script with${lcyan} correct assertions${NC}"
    echo "assert(getprop(\"ro.product.device\") == \"SGH-I757M\" || getprop(\"ro.build.product\") == \"SGH-I757M\" || " >> "$TF/META-INF/com/google/android/updater-script-tmp"
    echo "getprop(\"ro.product.device\") == \"SGH-I757\" || getprop(\"ro.build.product\") == \"SGH-I757\" || " >> "$TF/META-INF/com/google/android/updater-script-tmp"
    echo "getprop(\"ro.product.device\") == \"celoxhd\" || getprop(\"ro.build.product\") == \"celoxhd\" || " >> "$TF/META-INF/com/google/android/updater-script-tmp"
    echo "getprop(\"ro.product.device\") == \"SGHI757M\" || getprop(\"ro.build.product\") == \"SGHI757M\" || " >> "$TF/META-INF/com/google/android/updater-script-tmp"
    echo "getprop(\"ro.product.device\") == \"SGHI757\" || getprop(\"ro.build.product\") == \"SGHI757\");" >> "$TF/META-INF/com/google/android/updater-script-tmp"
    
    echo -e "${lcyan}Copying contents of existing ${NC}updater-script${lcyan} to ${NC}updater-script-tmp"
    cat "$TF/META-INF/com/google/android/updater-script" >> "$TF/META-INF/com/google/android/updater-script-tmp"
    
    echo -e "${lcyan}Copying ${NC}updater-script-tmp${lcyan} to ${NC}updater-script"
    cp "$TF/META-INF/com/google/android/updater-script-tmp" "$TF/META-INF/com/google/android/updater-script"
    
    echo -e "${lcyan}Removing ${NC}updater-script-tmp"
    rm -f "$TF/META-INF/com/google/android/updater-script-tmp"
    echo " "

    echo -e "${lcyan}Replacing build.prop values for ${NC}ro.build.type${lcyan}, ${NC}ro.product.locale.region${lcyan}, ${NC}ro.kernel.android.checkjni${lcyan} and ${NC}ro.sf.lcd_density${NC}"
    sed -i "s/ro\.build\.type=eng/ro\.build\.type=user/g" "$TF/system/build.prop"
    sed -i "s/ro\.product\.locale\.region=US/ro\.product\.locale\.region=CA/g" "$TF/system/build.prop"
    sed -i "s/ro\.kernel\.android\.checkjni=1/ro\.kernel\.android\.checkjni=0/g" "$TF/system/build.prop"
    sed -i "s/ro\.sf\.lcd_density=245/ro\.sf\.lcd_density=320/g" "$TF/system/build.prop"

    echo -e "${lcyan}Updating ${NC}META-INF"
    7z a "$ZIP" "$TF/META-INF"
    echo " "
    
    echo -e "${lcyan}Updating ${NC}system"
    7z a "$ZIP" "$TF/system"
    echo " "

    echo -e "${lcyan}Removing ${NC}OUT/tmp"
    rm -r "$TF"
    
    echo -e "${lcyan}Zip updated successfully${NC}"
    echo " "
fi

