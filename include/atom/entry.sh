#!/bin/bash

# atom/entry.sh - Functions to handle Atom feed entries
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
	if ! include "atom/common" "atom/xml"; then
		return 1
	fi

	return 0
}

atom_entry_new() {
	local feed="$1"
	local -i num="$2"

	local entry
	local id

	entry="$feed/entries/$num"
	if ! id=$(atom_common_random_id); then
		return 1
	fi

	if ! mkdir -p "$entry/links"; then
		return 1
	fi

	if ! printf '%s\n' "$id" > "$entry/id"; then
		rmdir "$entry"
		return 1
	fi

	printf '%s\n' "$entry"
	return 0
}

atom_entry_set_date() {
	local entry="$1"
	local type="${2-updated}"
	local date="$3"

	if [[ "$type" != "updated" && "$type" != "published" ]]; then
		return 1
	fi

	if ! atom_common_timestamp "$date" > "$entry/$type"; then
		return 1
	fi

	return 0
}

atom_entry_add_category() {
	local entry="$1"
	local term="$2"
	local label="$3"
	local scheme="$4"

	atom_common_file_append "$entry/categories" "$term:$scheme:$label"
}

atom_entry_set_content() {
	local entry="$1"
	local content="$2"
	local type="${3-text}"

	if ! printf '%s:%s\n' "$type" "$content" > "$entry/content"; then
		return 1
	fi

	return 0
}

atom_entry_add_author() {
	local entry="$1"
	local name="$2"
	local email="$3"
	local uri="$4"

	atom_common_file_append "$entry/authors" "$name:$email:$uri"
}

atom_entry_add_contributor() {
	local entry="$1"
	local name="$2"
	local email="$3"
	local uri="$4"

	atom_common_file_append "$entry/contributors" "$name:$email:$uri"
}

atom_entry_add_link() {
	local entry="$1"
	local rel="$2"
	local href="$3"
	local title="$4"
	local type="$5"
	local content="$6"

	local link

	link="$entry/links/$EPOCHREALTIME"

	if ! mkdir -p "$link"; then
		return 1
	fi

	if ! printf '%s\n' "$rel" > "$link/rel" ||
	   ! printf '%s\n' "$href" > "$link/href" ||
	   ! printf '%s\n' "$type" > "$link/type" ||
	   ! printf '%s\n' "$title" > "$link/title" ||
	   ! printf '%s\n' "$content" > "$link/content"; then
		return 1
	fi

	return 0
}

atom_entry_set_rights() {
	local entry="$1"
	local rights="$2"

	if ! printf '%s\n' "$rights" > "$entry/rights"; then
		return 1
	fi

	return 0
}

atom_entry_set_summary() {
	local entry="$1"
	local summary="$2"
	local type="${3-text}"

	if ! printf '%s:%s\n' "$type" "$summary" > "$entry/summary"; then
		return 1
	fi

	return 0
}

atom_entry_set_title() {
	local entry="$1"
	local title="$2"
	local type="${3-text}"

	if ! printf '%s:%s\n' "$type" "$title" > "$entry/title"; then
		return 1
	fi

	return 0
}

atom_entry_to_xml() {
	local entry="$1"

	local xml

	xml='<entry>'

	if [ -f "$entry/authors" ]; then
		xml+=$(atom_xml_persons "$entry/authors" "author")
	fi
	if [ -f "$entry/contributors" ]; then
		xml+=$(atom_xml_persons "$entry/contributors" "contributor")
	fi
	if [ -f "$entry/title" ]; then
		xml+=$(atom_xml_title "$entry/title")
	fi
	if [ -f "$entry/categories" ]; then
		xml+=$(atom_xml_categories "$entry/categories")
	fi

	xml+=$(atom_xml_id "$entry/id")
	if [ -f "$entry/content" ]; then
		xml+=$(atom_xml_content "$entry/content")
	fi
	if [ -f "$entry/rights" ]; then
		xml+=$(atom_xml_rights "$entry/rights")
	fi
	xml+=$(atom_xml_links "$entry/links")
	if [ -f "$entry/published" ]; then
		xml+=$(atom_xml_time "$entry/published")
	fi
	if [ -f "$entry/updated" ]; then
		xml+=$(atom_xml_time "$entry/updated")
	fi
	if [ -f "$entry/summary" ]; then
		xml+=$(atom_xml_summary "$entry/summary")
	fi

	xml+='</entry>'

	printf '%s\n' "$xml"
	return 0
}
