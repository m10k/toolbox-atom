#!/bin/bash

# atom/common.sh - Common functions of the Atom module
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
	return 0
}

atom_common_file_append() {
	local file="$1"
	local entry="$2"

	local match

	if ! match=$(grep -m 1 -F "$entry" "$file" 2>/dev/null) ||
	   [[ "$match" != "$entry" ]]; then
		if ! printf '%s\n' "$entry" >> "$file"; then
			return 1
		fi
	fi

	return 0
}

atom_common_timestamp() {
	local -i time="${1:-$EPOCHSECONDS}"

	date --date="@$time" --iso-8601=seconds
}

atom_common_random_id() {
	uuidgen --random
}
