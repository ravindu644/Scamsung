#!/bin/sh
################################################################################
# Copyright (c) [2023] [Ravindu Deshan]
#
# Unauthorized publication is prohibited. Forks and personal use are allowed.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
################################################################################
rm -rf "$(pwd)/Scamsung"
clone() {
    git clone https://github.com/ravindu644/Scamsung.git > /dev/null 2>&1
    cd Scamsung
    chmod +x -R bin/
    chmod +x scamsung.sh
}
clone
