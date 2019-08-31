#!/bin/sh -e
# license: WTFPLv2

# this is useful for jekyll-sitemap plugin
# https://github.com/jekyll/jekyll-sitemap#lastmod-tag

find -name '*.md' | while read f
do
	grep -q '^---$' "$f" || continue  # no front matter: not a jekyll file

	dt=$(git log -1 --format=%cI "$f")
	[ -n "$dt" ] || continue  # file isn't tracked by git

	if grep -q '^last_modified_at: ' "$f"
	then
		sed -i "s/^last_modified_at: .*$/last_modified_at: $dt/" "$f"
	else
		sed -i "s/^title: .*$/&\nlast_modified_at: $dt/" "$f"
	fi
done

