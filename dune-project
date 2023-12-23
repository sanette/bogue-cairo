(lang dune 2.7)
(version "0.1")
(name bogue-cairo)
(generate_opam_files true)
(license ISC)
(maintainers "Vu Ngoc San <san.vu-ngoc@laposte.net>")
(authors "Vu Ngoc San <san.vu-ngoc@laposte.net>")
(source (github sanette/tsdl-image))

(package
 (name bogue-cairo)
 (synopsis "Allow Cairo drawing functions to be used in Bogue's Sdl_area")
 (description
   "This library provides a special Cairo mode for Bogue Sdl_area.
    It also adds shortcuts for simple shapes (lines, circles, etc.)")
 (tags ("gui" "bogue" "graphics" "drawing" "cairo"))
 (depends
  (bogue (>= 20220217))
  cairo2))
