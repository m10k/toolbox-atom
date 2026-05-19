#!/bin/bash

# atom/xml.sh - XML generation functions for Atom feeds
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

atom_xml_content() {
	local file="$1"

	atom_xml_text "$file" "content"
}

atom_xml_title() {
	local file="$1"

	atom_xml_text "$file" "title"
}

atom_xml_subtitle() {
	local file="$1"

	atom_xml_text "$file" "subtitle"
}

atom_xml_summary() {
	local file="$1"

	atom_xml_text "$file" "summary"
}

atom_xml_text() {
	local file="$1"
	local kind="$2"

	local data
	local type
	local title

	if ! data=$(< "$file"); then
		return 1
	fi

	type="${data%%:*}"
	title="${data#*:}"

	printf '<%s type="%s">%s</%s>' "$kind" "$type" "$title" "$kind"
	return 0
}

atom_xml_logo() {
	local file="$1"

	atom_xml_tag "$file" "logo"
}

atom_xml_icon() {
	local file="$1"

	atom_xml_tag "$file" "icon"
}

atom_xml_rights() {
	local file="$1"

	atom_xml_tag "$file" "rights"
}

atom_xml_tag() {
	local file="$1"
	local tag="$2"

	local logo

	if ! logo=$(< "$file"); then
		return 1
	fi

	printf '<%s>%s</%s>\n' "$tag" "$logo" "$tag"
	return 0
}

atom_xml_persons() {
	local file="$1"
	local type="$2"

	local name
	local email
	local uri

	if [[ "$type" != "author" && "$type" != "contributor" ]]; then
		return 1
	fi

	while IFS=':' read -r name email uri; do
		if [[ -z "$name$email$uri" ]]; then
			continue
		fi

		printf '<%s>' "$type"
		if [[ -n "$name" ]]; then
			printf '<name>%s</name>' "$name"
		fi
		if [[ -n "$email" ]]; then
			printf '<email>%s</email>' "$email"
		fi
		if [[ -n "$uri" ]]; then
			printf '<uri>%s</uri>' "$uri"
		fi
		printf '</%s>' "$type"
	done < "$file"

	return 0
}

atom_xml_id() {
	local file="$1"

	local id

	if ! id=$(< "$file"); then
		return 1
	fi

	printf '<id>urn:uuid:%s</id>\n' "$id"
	return 0
}

atom_xml_time() {
	local file="$1"

	local time
	local type

	if ! time=$(< "$file"); then
		return 1
	fi

	type="${file##*/}"

	printf '<%s>%s</%s>\n' "$type" "$time" "$type"
	return 0
}

atom_xml_link() {
	local link="$1"

	local -A props
	local prop
	local xml

	props=(
		["href"]=""
		["rel"]=""
		["title"]=""
		["type"]=""
		["content"]="" # Technically not a property
	)

	for prop in "${!props[@]}"; do
		props["$prop"]=$(cat "$link/$prop" 2>/dev/null)
        done

	# Link tags must have a href attribute. Any
	# other attributes are optional.

	if [[ -z "${props["href"]}" ]]; then
		return 1
	fi

	xml="<link href=\"${props["href"]}\""

	for prop in "rel" "title" "type"; do
		if [[ -n "${props["$prop"]}" ]]; then
			xml+=" $prop=\"${props["$prop"]}\""
		fi
	done

	if [[ -n "${props["content"]}" ]]; then
		xml+=">${props["content"]}</link>"
	else
		xml+=" />"
	fi

	printf '%s\n' "$xml"
	return 0
}

atom_xml_links() {
	local linkdir="$1"

	local link
	local -i err

	err=0

	while read -r link; do
		if ! atom_xml_link "$link"; then
			err=1
		fi
	done < <(find "$linkdir" -mindepth 1 -maxdepth 1 -type d)

	return "$err"
}

atom_xml_categories() {
	local file="$1"

	local term
	local scheme
	local label
	local -i err

	err=1

	while IFS=':' read -r term scheme label; do
		local category

		category="<category"

		if [[ -n "$term" ]]; then
			category+=" term=\"$term\""
		fi
		if [[ -n "$scheme" ]]; then
			category+=" scheme=\"$scheme\""
		fi
		if [[ -n "$label" ]]; then
			category+=" label=\"$label\""
		fi
		category+=" />"

		printf '%s\n' "$category"
		err=0
	done < "$file"

	return "$err"
}

atom_xml_generator() {
	local file="$1"

	local uri
	local version
	local name

	if ! IFS=':' read -r name version uri < "$file"; then
		return 1
	fi

	printf '<generator uri="%s" version="%s">%s</generator>' "$uri" "$version" "$name"
	return 0
}
