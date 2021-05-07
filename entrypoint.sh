#!/bin/bash

RED="\e[31m"
CLEAR="\e[0m"

if [[ -z "$INPUT_LOCATION" ]]
then
    INPUT_LOCATION=scratch
    INPUT_SIM_NAME=scratch/workspace/workspace
fi

# copy all of the files into the scratch folder
cp -r "$GITHUB_WORKSPACE" /ns3/ns-allinone-${NS3_VERSION}/ns-${NS3_VERSION}/$INPUT_LOCATION/
cd  /ns3/ns-allinone-${NS3_VERSION}/ns-${NS3_VERSION}

if [[ ! -z "$INPUT_PRE_RUN" ]]
then
    echo $INPUT_PRE_RUN | sh
    res=$?
    if [[ "$res" -ne "0" ]]
    then
        echo -e "${RED}pre-run script failed, exiting early${CLEAR}"
        exit $res
    fi
fi

# only reconfigure if it is in a core location
if [[ "$INPUT_LOCATION" != "scratch" ]]
then
    ./waf configure --enable-tests --enable-examples
    res=$?
    if [[ "$res" -ne "0" ]]
    then
        echo -e "${RED}waf configuration failed${CLEAR}"
        exit $res
    fi
fi

# test build the app
./waf build

res=$?
if [[ "$res" -ne "0" ]]
then
    echo -e "${RED}waf build was unsuccessfull${CLEAR}"
    exit $res
fi

# run a test simulation to ensure that it runs if a parameter is set
if [[ -z "$INPUT_SIM_ARGS" ]]
then
    echo "No simulation arguments given, not running a sample run"
else
    ./waf --run "$INPUT_SIM_NAME $INPUT_SIM_ARGS"
    res=$?
    if [[ "$res" -ne "0" ]]
    then
        echo -e "${RED}Simulation run could not be compleeted successfully${CLEAR}"
        exit $res
    fi
fi

if [[ ! -z "$INPUT_POST_RUN" ]]
then
    echo $INPUT_POST_RUN | sh
    exit $?
fi
