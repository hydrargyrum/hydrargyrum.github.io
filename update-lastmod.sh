#!/bin/sh -e
# license: WTFPLv2

# this is useful for jekyll-sitemap plugin
# https://github.com/jekyll/jekyll-sitemap#lastmod-tag

git ls-files '*.md' | while read f
do
	grep -q '^---$' "$f" || continue  # no front matter: not a jekyll file

	dt=$(git log -1 --grep last_modified_at --invert-grep --format=%aI "$f")

	if grep -q '^last_modified_at: ' "$f"
	then
		sed -i "s/^last_modified_at: .*$/last_modified_at: $dt/" "$f"
	else
		sed -i "s/^title: .*$/&\nlast_modified_at: $dt/" "$f"
	fi
done

