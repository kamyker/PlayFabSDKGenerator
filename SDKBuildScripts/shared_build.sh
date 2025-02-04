#!/bin/bash

. "$WORKSPACE/SDKGenerator/JenkinsConsoleUtility/JenkinsScripts/sdkUtil.sh" 2> /dev/null || . "../JenkinsConsoleUtility/JenkinsScripts/sdkUtil.sh" 2> /dev/null

# Mandatory Variable Checks
if [ -z "$SdkName" ]; then
    echo Mandatory parameters not defined: SdkName=$SdkName targetSrc=$targetSrc
    exit 1
fi

# Functions

# USAGE NukeAll <pattern>
NukeAll () {
    find . -name "$1" -exec rm -f {} \; 2> /dev/null || true
}

RemoveEmptyDirectories() {
    find . -type d -empty -delete 2> /dev/null || true
}

# USAGE CleanCodeFiles
CleanCodeFiles () {
    pushd "../$destPath"
    NukeAll "*.as"
    NukeAll "*.cpp"
    NukeAll "*.cs"
    NukeAll "*.h"
    NukeAll "*.java"
    NukeAll "*.js"
    NukeAll "*.lua"
    NukeAll "*.m"
    NukeAll "*.php"
    NukeAll "*.py"
    NukeAll "*.ts"
    RemoveEmptyDirectories
    # cmd <<< "attrib -H *.meta /S /D" # Doesn't seem to be working...
    popd
}

BuildSdk () {
    pushd ..
    echo === SHARED BUILDING $SdkName ===
    if [ ! -z "$SdkGenPrvTmplRepo" ]; then
        node generate.js $SdkGenPrvTmplRepo=$destPath $apiSpecSource $SdkGenArgs $buildIdentifier $VerticalNameInternal
    elif [ -z "$targetSrc" ]; then
        node generate.js -destPath $destPath $apiSpecSource $SdkGenArgs $buildIdentifier $VerticalNameInternal
    else
        node generate.js $targetSrc=$destPath $apiSpecSource $SdkGenArgs $buildIdentifier $VerticalNameInternal
    fi
    popd
}

# Set the script-internal variables
destPath="../sdks/$SdkName"
CheckApiSpecSourceDefault
CheckBuildIdentifierDefault
CheckVerticalNameInternalDefault

# Do the work
if [ "$delSrc" = "true" ]; then
    CleanCodeFiles
fi
BuildSdk

