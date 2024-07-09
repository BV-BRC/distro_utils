# Distribution Build Utilities

This module contains utility code and data used in the creation of BV-BRC distributions.

## Overview

A distribution is comprised of two primary components: a distribution configuration file
that defines the contents of the distribution and the details of that configuration, and
a service registry that defines the endpoints of the services used in this distribution.

The distribution config file is named distro.cfg. It is a template for a
master deployment configuration file for the distribution. As such it defines
the modules included in the distribution as well as the configuration required
for each module.

The registry is a file defining the values to be substituted in the distribution config
that define the endpoints for the services used in the distribution.
