#!/bin/sh -e
# license: WTFPLv2

# this is useful for jekyll-sitemap plugin
# https://github.com/jekyll/jekyll-sitemap#lastmod-tag

update_file_meta () {
	grep -q '^---$' "$1" || return  # no front matter: not a jekyll file

	if grep -q '^last_modified_at: ' "$1"
	then
		sed -i "s/^last_modified_at: .*$/last_modified_at: $2/" "$1"
	else
		sed -i "s/^title: .*$/&\nlast_modified_at: $2/" "$1"
	fi
}

get_date () {
	git log -1 --grep last_modified_at --invert-grep --format=%aI "$1"
}

if [ $# -eq 0 ]
then
	git ls-files '*.md' | while read f
	do
		update_file_meta "$f" "$(get_date "$f")"
	done
else
	update_file_meta "$1" "$(get_date "$1")"
fi

