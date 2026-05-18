#!/bin/bash

# atom.sh - Atom module for toolbox
# Copyright (C) 2026 Matthias Kruk
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

__init() {
	declare -gxr __atom_root="$TOOLBOX_HOME/atom"
	declare -gxr __atom_generator_uri="https://m10k.eu/toolbox"
	declare -gxr __atom_generator_version="unstable"
	declare -gxr __atom_generator_name="toolbox-atom"

	if ! include "atom/common" "atom/entry" "atom/feed" "atom/xml"; then
		return 1
	fi

	return 0
}
