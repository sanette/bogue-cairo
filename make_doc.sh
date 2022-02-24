#!/bin/bash -ve

cd /home/san/prog/ocaml/bogue-cairo/dune-version
dune build @doc
rsync -avz --delete _build/default/_doc/_html/bogue-cairo/Bogue_cairo/ docs
for file in "docs/index.html" "docs/Cairo_area/index.html"
do
  sed -i "s|../../||g" $file
  sed -i "s|<span>&#45;&gt;</span>|<span class=\"arrow\">→</span>|g" $file
done

sed -i "s| (bogue-cairo.Bogue_cairo)||g" docs/index.html
cp ./_build/default/_doc/_html/odoc.css docs/
chmod 644 docs/odoc.css
cp _build/default/_doc/_html/highlight.pack.js docs/
echo "header nav {display: none;} header nav.toc {display: block;} header dl dd, header dl dt {display: inline-block;} " >>  docs/odoc.css

echo "Done"
