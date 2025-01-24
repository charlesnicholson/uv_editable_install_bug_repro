#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
UV="$SCRIPT_DIR/uv"
VENV="$SCRIPT_DIR/venv"

# Clean everything from the last run.
rm -rf $VENV
rm -rf $SCRIPT_DIR/repro_p1/repro_p1/test2.py
rm -rf $SCRIPT_DIR/repro_p1/repro_p1.egg-info
rm -rf $SCRIPT_DIR/repro_p1/build
rm -rf $SCRIPT_DIR/repro_p1/dist
rm -rf $SCRIPT_DIR/repro_p1/__pycache__
rm -rf $SCRIPT_DIR/repro_p2/repro_p2.egg-info
rm -rf $SCRIPT_DIR/repro_p2/build
rm -rf $SCRIPT_DIR/repro_p2/dist
rm -rf $SCRIPT_DIR/repro_p2/__pycache__
$UV cache clean

# Create the venv and editable-install the two repro packages:
#
$UV venv -p python3.13 $VENV

$UV pip install \
        -p $VENV/bin/python \
        -e $SCRIPT_DIR/repro_p1 \
        --config-settings editable_mode=strict

$UV pip install \
        -p $VENV/bin/python \
        -e $SCRIPT_DIR/repro_p2 \
        --config-settings editable_mode=strict

# The initial environment is now set up.

# This command succeeds because p2.test_p2() uses repro_p1/test.py, which exists.
$VENV/bin/python -c "from repro_p2 import p2; p2.test_p2()"

# Simulate a user adding a new test2.py file to the repro_p1 package:
printf '%s\n' 'def test2_p1():' '    print("Hello from test2")' >> $SCRIPT_DIR/repro_p1/repro_p1/test2.py

# This command should install a new test2.py symlink in repro_p1's build directory.
$UV pip install \
        -p $VENV/bin/python \
        -e $SCRIPT_DIR/repro_p1 \
        --config-settings editable_mode=strict

# This command fails because uv didn't add a test2.py symlink to repro_p1's build dir.
$VENV/bin/python -c "from repro_p2 import p2; p2.test_p2_against_changed_p1()"
