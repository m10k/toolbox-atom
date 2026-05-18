#!/bin/bash

# atom/feed.sh - Functions for handling Atom feeds
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
	if ! include "atom/common" "atom/entry" "atom/xml"; then
		return 1
	fi

	return 0
}

atom_feed_new() {
	local feed="$1"

	local feed_root
	local -a dirs
	local id

	feed_root="$__atom_root/$feed"
	dirs=(
		"$feed_root/entries"
		"$feed_root/links"
	)

	if ! mkdir -p "${dirs[@]}"; then
		return 1
	fi

	if ! [ -e "$feed_root/id" ]; then
		if ! atom_common_random_id > "$feed_root/id"; then
			return 1
		fi
	fi

	printf '%s\n' "$feed_root"
	return 0
}

atom_feed_list_entries() {
	local feed="$1"

	find "$feed/entries" -mindepth 1 -maxdepth 1 -type d |
		sort --version-sort
}

atom_feed_add_entry() {
	local feed="$1"

	local last_entry
	local -i last_entry_num
	local -i next_entry_num

	last_entry=$(atom_feed_list_entries "$feed" | tail -n 1)
	if [[ -z "$last_entry" ]]; then
		last_entry_num=0
	else
		last_entry_num="${last_entry##*/}"
	fi
	next_entry_num=last_entry_num+1

	if ! atom_entry_new "$feed" "$next_entry_num"; then
		return 1
	fi

	return 0
}

atom_feed_get_entries_xml() {
	local feed="$1"

	local xml
	local entry
	local -i err

	xml=""
	err=0

	while read -r entry; do
		if ! xml+=$(atom_entry_to_xml "$entry"); then
			err=1
			break
		fi
	done < <(atom_feed_list_entries "$feed")

	if (( !err )); then
		printf '%s\n' "$xml"
	fi

	return "$err"
}

atom_feed_add_author() {
	local feed="$1"
	local name="$2"
	local email="$3"
	local uri="$4"

	atom_common_file_append "$feed/authors" "$name:$email:$uri"
}

atom_feed_add_category() {
	local feed="$1"
	local term="$2"
	local label="$3"
	local scheme="$4"

	atom_common_file_append "$feed/categories" "$term:$scheme:$label"
}

atom_feed_add_contributor() {
	local feed="$1"
	local name="$2"
	local email="$3"
	local uri="$4"

	atom_common_file_append "$feed/contributors" "$name:$email:$uri"
}

atom_feed_add_link() {
	local feed="$1"
	local rel="$2"
	local href="$3"
	local title="$4"
	local type="${5-text}"

	local -i id
	local link

	id="$EPOCHREALTIME"
	link="$feed/links/$id"

	if ! mkdir -p "$link"; then
		return 1
	fi

	if ! printf '%s\n' "$rel" > "$link/rel" ||
	   ! printf '%s\n' "$href" > "$link/href" ||
	   ! printf '%s:%s\n' "$type" "$title" > "$link/title"; then
		return 1
	fi

	return 0
}

atom_feed_set_logo() {
	local feed="$1"
	local logo="$2"

	if ! printf '%s\n' "$logo" > "$feed/logo"; then
		return 1
	fi

	return 0
}

atom_feed_set_icon() {
	local feed="$1"
	local icon="$2"

	if ! printf '%s\n' "$icon" > "$feed/icon"; then
		return 1
	fi

	return 0
}

atom_feed_set_date() {
	local feed="$1"
	local time="$2"

	if ! atom_common_timestamp "$time" > "$feed/updated"; then
		return 1
	fi

	return 0
}

atom_feed_set_rights() {
	local feed="$1"
	local rights="$2"

	if ! printf '%s\n' "$rights" > "$feed/rights"; then
		return 1
	fi

	return 0
}

atom_feed_set_title() {
	local feed="$1"
	local title="$2"
	local type="${3-text}"

	if ! printf '%s:%s\n' "$type" "$title" > "$feed/title"; then
		return 1
	fi

	return 0
}

atom_feed_set_subtitle() {
	local feed="$1"
	local title="$2"
	local type="${3-text}"

	if ! printf '%s:%s\n' "$type" "$title" > "$feed/subtitle"; then
		return 1
	fi

	return 0
}

atom_feed_to_xml() {
	local feed="$1"

	local xml

	xml='<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
'
	if [ -f "$feed/authors" ]; then
		xml+=$(atom_xml_persons "$feed/authors" "author")
	fi
	if [ -f "$feed/contributors" ]; then
		xml+=$(atom_xml_persons "$feed/contributors" "contributors")
	fi
	if [ -f "$feed/categories" ]; then
		xml+=$(atom_xml_categories "$feed/categories")
	fi

	if ! [ -f "$feed/generator" ] ||
	   ! xml+=$(atom_xml_generator "$feed/generator"); then
		xml+=$(printf '<generator uri="%s" version="%s">%s</generator>'   \
		              "$__atom_generator_uri" "$__atom_generator_version" \
		              "$__atom_generator_name")
	fi

	if [ -f "$feed/id" ]; then
		xml+=$(atom_xml_id "$feed/id")
	fi

	if [ -f "$feed/icon" ]; then
		xml+=$(atom_xml_icon "$feed/icon")
	fi

	xml+=$(atom_xml_links "$feed/links")
	if [ -f "$feed/logo" ]; then
		xml+=$(atom_xml_logo "$feed/logo")
	fi
	if [ -f "$feed/rights" ]; then
		xml+=$(atom_xml_rights "$feed/rights")
	fi
	if [ -f "$feed/subtitle" ]; then
		xml+=$(atom_xml_subtitle "$feed/subtitle")
	fi
	if [ -f "$feed/title" ]; then
		xml+=$(atom_xml_title "$feed/title")
	fi
	if [ -f "$feed/updated" ]; then
		xml+=$(atom_xml_time "$feed/updated")
	fi

	xml+=$(atom_feed_get_entries_xml "$feed")

	xml+='</feed>'

	printf '%s\n' "$xml"
	return 0
}
