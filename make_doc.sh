#!/bin/bash -ve

# This requires dune >= 3.8.0
# see https://github.com/ocaml/dune/issues/7364

dune build @doc
rsync -avz --delete _build/default/_doc/_html/bogue-cairo/Bogue_cairo/ docs
for file in "docs/index.html" "docs/Cairo_area/index.html"
do
  sed -i "s|../../||g" $file
  sed -i "s|<span>&#45;&gt;</span>|<span class=\"arrow\">→</span>|g" $file
done

sed -i "s| (bogue-cairo.Bogue_cairo)||g" docs/index.html
cp -r ./_build/default/_doc/_html/odoc.support docs/
chmod 644 docs/odoc.support/odoc.css
cat addon.css >>  docs/odoc.support/odoc.css

mkdir -p docs/images
cp -r images/* docs/images/

echo "Done"
