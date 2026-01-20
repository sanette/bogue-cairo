(lang dune 2.8)
(version "0.1.0")
(name bogue-cairo)
(generate_opam_files true)
(license ISC)
(maintainers "Vu Ngoc San <san.vu-ngoc@laposte.net>")
(authors "Vu Ngoc San <san.vu-ngoc@laposte.net>")
(source (github sanette/bogue-cairo))

(package
 (name bogue-cairo)
 (synopsis "Allow Cairo drawing functions to be used in Bogue's Sdl_area")
 (description
   "This library provides a special Cairo mode for Bogue Sdl_area.
    It also adds shortcuts for simple shapes (lines, circles, etc.)")
 (tags ("gui" "bogue" "graphics" "drawing" "cairo"))
 (depends
  (dune :build)
  (bogue (>= 20220418))
  cairo2))
