#!/usr/bin/env python3

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2014-2022, Lars Asplund lars.anders.asplund@gmail.com

"""
abp_runctl vunit test

"""

from pathlib import Path
from vunit import VUnit

VU = VUnit.from_argv()

SRC_PATH = Path(__file__).parent

vlib = VU.add_library("axpc_lib")
vlib.add_source_files(SRC_PATH.parent / "scnn_lfsr9.vhd")
vlib.add_source_files(SRC_PATH.parent / "scnn_s2b_buffer.vhd")
vlib.add_source_files(SRC_PATH.parent / "scnn_b2s_buffer.vhd")
vlib.add_source_files(SRC_PATH.parent / "scnn_sng.vhd")
vlib.add_source_files(SRC_PATH.parent / "scnn_accumulator.vhd")
VU.add_library("tb_axpc_lib").add_source_files(SRC_PATH / "tb_axpc.vhd")

VU.main()
