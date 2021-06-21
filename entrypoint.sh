#!/bin/bash

RED="\e[31m"
GREEN="\e[33m"
YELLOW="\e[33m"
CLEAR="\e[0m"

module=$(basename $GITHUB_REPOSITORY)

if [[ -z "$INPUT_LOCATION" ]]
then
    INPUT_LOCATION=scratch
    INPUT_SIM_NAME=scratch/$module/$module
fi

# sym link all of the files into the scratch folder
ln -s $GITHUB_WORKSPACE /ns3/ns-allinone-${NS3_VERSION}/ns-${NS3_VERSION}/$INPUT_LOCATION/$module
cd  /ns3/ns-allinone-${NS3_VERSION}/ns-${NS3_VERSION}

if [[ ! -z "$INPUT_PRE_RUN" ]]
then
    echo "Running pre run script..."
    echo "$GITHUB_WORKSPACE/$INPUT_PRE_RUN" | sh
    res=$?
    if [[ "$res" -ne "0" ]]
    then
        echo -e "${RED}pre-run script failed, exiting early${CLEAR}"
        exit $res
    fi

    echo -e "Prerun script complete\n\n"
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

    echo "Reconfiguring waf was succsessful"
fi

# test build the app
./waf build

res=$?
if [[ "$res" -ne "0" ]]
then
    echo -e "${RED}waf build was unsuccessfull${CLEAR}"
    exit $res
fi

# run a test simulation to ensure that it runs
if [[ -z "$INPUT_SIM_NAME" ]]
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
    echo "Running post simulation run script"

    echo "$GITHUB_WORKSPACE/$INPUT_POST_RUN" | sh
    exit $?
fi
