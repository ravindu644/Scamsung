#!/bin/bash

################################################################################
# Copyright (c) [2023] [Ravindu Deshan]
#
# Unauthorized publication is prohibited. Forks and personal use are allowed.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
################################################################################

clone(){
	git clone https://github.com/ravindu644/Scamsung.git; cd Scamsung
	chmod +x -R bin/
	bash scamsung.sh
}

clone