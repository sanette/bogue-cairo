# bogue-cairo

Add-on to [BOGUE](https://github.com/sanette/bogue).

This library enables the use of Cairo drawing functions in Bogue's Sdl_area.

# Example

We rewrote Example #50 from the BOGUE distribution using
Bogue-cairo.
```
dune exec bin/circles.exe
```
Here is the result.

![Cairo circles](https://github.com/sanette/bogue-cairo/blob/main/docs/images/cairo-circles.png)

You may compare the original
[BOGUE circle primitive](http://sanette.github.io/bogue/Bogue.Sdl_area.html#VALdraw_circle)
(and notice that the interpretation of alpha and anti-aliasing is
slightly different). The Cairo version is twice as fast.
