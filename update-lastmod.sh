#!/bin/sh -e
# license: WTFPLv2

# this is useful for jekyll-sitemap plugin
# https://github.com/jekyll/jekyll-sitemap#lastmod-tag

update_file_meta () {
	grep -q '^---$' "$1" || continue  # no front matter: not a jekyll file

	dt=$(git log -1 --grep last_modified_at --invert-grep --format=%aI "$1")

	if grep -q '^last_modified_at: ' "$1"
	then
		sed -i "s/^last_modified_at: .*$/last_modified_at: $dt/" "$1"
	else
		sed -i "s/^title: .*$/&\nlast_modified_at: $dt/" "$1"
	fi
}

if [ $# -eq 0 ]
then
	git ls-files '*.md' | while read f
	do
		update_file_meta "$f"
	done
else
	update_file_meta "$1"
fi

