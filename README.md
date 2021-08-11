![docker deploy on main](https://img.shields.io/github/workflow/status/marshallasch/ns3-action/action-deploy/main?style=plastic)
![GitHub](https://img.shields.io/github/license/marshallasch/ns3-action?style=plastic)
![Lines of code](https://img.shields.io/tokei/lines/github/marshallasch/ns3-action?style=plastic)
![ns-3 version](https://img.shields.io/badge/NS--3-3.34-blueviolet?style=plastic)
![Docker Pulls](https://img.shields.io/docker/pulls/marshallasch/ns3?style=plastic)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/marshallasch/ns3/34.1?style=plastic)

# ns-3 CI Checker

This action is used to test [ns-3](https://www.nsnam.org/) simulation code to check that it builds
and that a simple simulation can run without crashing. 

## Motivation

The ns-3 network simulation platform is an interesting codebase that is different from most other
library projects, where instead of including the simulator as a project dependency the simulation
code needs to be written _inside_ of the simulator code.
This presents some challenges with doing CI/CD testing on the simulation code that is being
written because you can not check to make sure that the code compiles without also compiling the 
entire simulator as well.
This is an extremely time consuming process (the github action to build this container takes about 23
minutes to run), that is no good for a simple "does this compile check", hence this project.

## Building

This repository is not meant to be built or used on its own, however it can be built manually.
The only dependency needed to build this is docker, and more than 2 GB of ram, I think 4GB might be needed
or it will crash part way through. 

```bash
$ docker built -t marshallasch/ns3 .
```

That is all that is needed to build the docker container, you do not need to have the ns3 codebase installed
because it will download a fresh copy of the `ns3-allinone` version when building the container. 

By default it will build ns-3 version 3.34, as that is the version of the simulator that I am using for my
research.
But a different version can be specified:

```bash
$ docker build --build-arg NS3_VERSION=3.33 marshallasch/ns3 .
```

The only potential shortcoming of that is if there are different system dependencies needed for different
versions of ns3, although it _should_ be fine.

One thing to note about this container is that it does not support any visualization, python bindings, tests,
examples, or any extra modules that can not be run from within the `scratch` folder. 

## Usage

### Inputs


#### `sim_name`

**optional** The extra options that are passed to the `./waf --run "<simulation name>  <options>"` 
to test run the simulation. 
Only specify this if the `location` is being set to something other than `scratch`, 
otherwise it is ignored.

#### `sim_args`

**optional** The extra options that are passed to the `./waf --run "<simulation name> <options>"` 
to test run the simulation. 
It is also important to note that this container is not designed to actually run simulations in
and these arguments should be  selected so that the smallest possible simulation can be run to ensure
that the code works. 

#### `pre_run`

**optional** A script that can be specified to run before the simulation code get compiled or run.

Note that this will be run from the NS3 directory, the script directory must be relative to the repository root and should not include a leading '/'


#### `post_run`

**optional** A script that can be specified to run before the simulation code get compiled or run. If this is specified then the return value of this script is used.

Note that this will be run from the NS3 directory, the script directory must be relative to the repository root and should not include a leading '/'

#### `location`

**optional** The location that the simulation code should be copied.
This should only be one of `scratch`, `src`, or `contrib`. 
The value will default to `scratch` if it is not set.
If it is set to `scratch` then the `sim_name` field is optional, for any other value it is required.



Also note that there is no output that is collected from this container and it is only used to check
that 1) the code builds, and 2) that the code runs without crashing. 

### Example usage

```yaml
name: build-ns3

on: [push, pull_request]

jobs:
  build-on-ns3:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2
    - name: ns3 build
      uses: marshallasch/ns3-action@3.34.1
      with:
        location: 'contrib'
        sim_name: 'saf-example'
        sim_args: '--run-time=900 --total-nodes=5'
```

## Special Thanks

I would like to acknowledge Dr. Jason Ernst ([@compscidr](https://github.com/compscidr))
who gave me the idea to implement this pipeline stage to help validate that my simulation code
actually builds. 
