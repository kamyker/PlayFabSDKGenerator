#!/bin/bash

. "$WORKSPACE/SDKGenerator/JenkinsConsoleUtility/JenkinsScripts/util.sh" 2> /dev/null || . ./util.sh 2> /dev/null
. "$WORKSPACE/SDKGenerator/JenkinsConsoleUtility/JenkinsScripts/sdkUtil.sh" 2> /dev/null || . ./sdkUtil.sh 2> /dev/null

CheckDefault PublishToS3 false

DoGitFinalize() {
    ForcePushD "$WORKSPACE/sdks/$SdkName"
    echo === Commit to Git ===
    git fetch --progress origin
    git add -A
    git commit --allow-empty -m "$CommitMessage"
    git push origin $GitDestBranch -f -u || (git fetch --progress origin && git push origin $GitDestBranch -f -u)
    popd
}

DoPublishToS3() {
    cd "$WORKSPACE"
    pushd "sdks/$SdkName"
    git clean -dfx
    popd
    
    rm -f repo.zip || true
    7z a -r repo.zip "sdks/$SdkName"

    CheckDefault VerticalName master
    aws s3 cp repo.zip s3://playfab-sdk-dist/$VerticalName/$SdkName/$(date +%y%m%d)_${S3BuildNum}_$SdkName.zip --profile jenkins
}

CheckVerticalizedParameters
if [ "$GitDestBranch" != "doNotCommit" ]; then
    DoGitFinalize
fi
if [ "$PublishToS3" = "true" ] && [ ! -z "S3BuildNum" ] && [ "S3BuildNum" != "0" ]; then
    DoPublishToS3
fi
