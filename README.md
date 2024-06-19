distro_utils
============

This module contains utility code and data used in the creation of BV-BRC distributions.

Overall plan:

A distribution is comprised of two primary components: a distribution config file
that defines the contents of the distribution and the details of that configuration, and
a service registry that defines the endpoints of the services used in this distribution.

The distribution config file is named distro.cfg. It is a template for a 
master deployment configuration file for the distribution. As such it defines 
the modules included in the distribution as well as the configuration required 
for each module. 

The registry is a file defining the values to be substituted in the distribution config
that define the endpoints for the services used in the distribution.

====

First phase: create manifest

1. For each module in checkout list from distro.cfg + dev_container, use

curl -i https://api.github.com/repos/kbase/typecomp/branches/master

to get the commit hash. Write manifest.

2. Edit release notes, readme, etc.

3. Assign release number.

4. Commit and push distro module back to git. Create release.

====

Contents of distro repo:

README
ReleaseNotes
Manifest
distro.cfg
localize.cfg
VERSION 

1. Clone Distro
2. cd to Distro, clone Distro-Tools
3. Define verison number, save in VERSION (distro-tools/set-version)
4. Edit readme, release notes etc.
5. distro-tools/create-manifest
6. commit and push distro
7. distro-tools/create-draft-release

==== 

For each desired artifact (DMG, native-client, docker image, windows installer)
    create artifact
    add to draft release

QA

Publish release

====


We need to fill in the following template variables:

target = instalation target
runtime = runtime directory

clients = list of clients
services = list of services
masters = list of "master"s

globus params:

globus_token_url
globus_profile_url
trust_token_signers

===

Creating an updated distribution:

  519  mkdir rasttk-release-2016-0114
  520  cd rasttk-release-2016-0114
  521  (cd ../rasttk-release-2015-0402/distro_utils/; git remote -v)
  522  (cd ../rasttk-release-2015-0402/RASTtk-Distribution/; git remote -v)
  523  git clone git@github.com:kbase/distro_utils
  524  git clone https://github.com/TheSEED/RASTtk-Distribution
  
  cd distro_utils
  ./bootstrap runtime-dir
  . user-env-sh
  
  cd ../RASTtk-Distribution
  create-manifest
  checkout-from-manifest ../build-mac-1
  distro-build-mac-app --app-name RASTtk ../build-mac-1
  distro-build-mac-dmg ../build-mac-1

Ubuntu:

env SHELL=/bin/bash distro-build-ubuntu-app --app-name RASTtk build-dir
