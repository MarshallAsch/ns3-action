#!/bin/bash

# copy all of the files into the scratch folder
cp -r "$GITHUB_WORKSPACE/*" /ns3/ns-allinone-${NS3_VERSION}/ns-${NS3_VERSION}/scratch/


# test build the app
./waf build
