# Getting container distribution overview

## Goal

Get a nice overview of how your plan resources are distributed to containers. It also shows current usage. Nice for when you want to diagnose performance issues.

## Screenshot

![Resources Overview](/screenshots/show_container_distribution.png?raw=true "Container distribution overview")

## Usage

Usage: 
  `bash show_container_distribution.sh $PROJECT_ID $ENV_NAME (defaults to: main)`

For example: 
  `bash show_container_distribution.sh szr3gqubqrd2y master`

Alternatively, just running it in a platform project will also work, since it reads the same config.yaml the platform/upsun cli can read

`bash show_container_distribution.sh $PROJECT_ID $ENV`


# Pre-requisites
- bash
- Platform CLI installed [documentation](https://fixed.docs.upsun.com/administration/cli.html)
- OR Upsun CLI installed [documentation](https://docs.upsun.com/administration/cli.html)

# Installation

Not really anything to install, this is a bash script that can be freely copy pasted.
You can `git clone` the repo, or look at [the source](https://raw.githubusercontent.com/matthiaz/upsun_tools/refs/heads/main/show_container_distribution.sh) directly. 


I prefer to have it cloned, and I have the folder added to `$PATH`.
