#!/bin/sh

# Activate virtualenv
cd /home/assos/sauron
. bin/activate

# Launch sauron
cd sauron
fab "$@"
