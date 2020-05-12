# /bin/sh

# This script MUST be run from within helm-charts directory
# This script assumes the following directories exist:
# ../cloudman-helm
# ../cloudlaunch-helm
# ../galaxy-helm
# This script will package cloudlaunch, cloudlaunchserver, cloudman, and galaxy
# and use the packaged version of each as a dependency for the next for the above charts
# (i.e. one does not have to change the dependencies of each of the charts to point to their
# fork, the final packaged cloudman will have the packaged cloudlaunch version, and not the one
# downloaded from the dependency.yml)

REPO_NAME=almahmoud
BRANCH_NAME=master
# Packaged CLServer and CL charts are automatically added as the dependency charts for
# CL and CM respectively
CL_VERSION=0.4.0
CLSERVER_VERSION=0.4.0

rm -rf ../cloudlaunch-helm/cloudlaunchserver/charts
rm -rf ../cloudlaunch-helm/cloudlaunch/charts
rm -rf ../cloudman-helm/cloudman/charts
rm -rf ../galaxy-helm/galaxy/charts
rm -rf ../cloudlaunch-helm/cloudlaunchserver/tmpcharts
rm -rf ../cloudlaunch-helm/cloudlaunch/tmpcharts
rm -rf ../cloudman-helm/cloudman/tmpcharts
rm -rf ../galaxy-helm/galaxy/tmpcharts
cd ../cloudlaunch-helm/cloudlaunchserver
helm dependency update
cd ../../cloudman-helm/cloudman
helm dependency update
cd ../../helm-charts/charts
echo "\nPackaging cloudlaunchserver!\n"
helm package ../../cloudlaunch-helm/cloudlaunchserver/
mkdir -p ../../cloudlaunch-helm/cloudlaunch/charts
cp cloudlaunchserver-$CLSERVER_VERSION.tgz ../../cloudlaunch-helm/cloudlaunch/charts/
echo "\nPackaging cloudlaunch!\n"
helm package ../../cloudlaunch-helm/cloudlaunch
cp cloudlaunch-$CL_VERSION.tgz ../../cloudman-helm/cloudman/charts/
echo "\nPackaging cloudman!\n"
helm package ../../cloudman-helm/cloudman/
export CHARTS_DIR=$(pwd)
cd ../../galaxy-helm/galaxy
helm dependency update
echo "\nPackaging galaxy!\n"
sh scripts/helm_package $CHARTS_DIR
cd ../../helm-charts/charts
echo "\nPackaging Galaxy CVMFS-CSI!\n"
helm package ../../galaxy-cvmfs-csi-helm/galaxy-cvmfs-csi/
cd ..
rm -f index.yaml
echo "\nReindexing!\n"
helm repo index . --url https://raw.githubusercontent.com/$REPO_NAME/helm-charts/$BRANCH_NAME/
