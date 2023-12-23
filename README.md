# bogue-cairo

Add-on to [Bogue](https://github.com/sanette/bogue).

[Cairo](https://www.cairographics.org/) is a famous cross-platform 2D
graphics library.

The `bogue-cairo` library enables the use of Cairo drawing functions
in Bogue's
[Sdl_area](http://sanette.github.io/bogue/Bogue.Sdl_area.html).

# Examples

## Circles

We rewrote Example #50 from the Bogue distribution using
Bogue-cairo. Here is the result.

![Cairo circles](https://github.com/sanette/bogue-cairo/blob/main/docs/images/cairo-circles.png)

You may compare the original
[BOGUE circle primitive](http://sanette.github.io/bogue/Bogue.Sdl_area.html#VALdraw_circle)
(and notice that the interpretation of alpha and anti-aliasing is
slightly different). The Cairo version is twice as fast.

## Lines

Compare Bogue's Example #51.

![Cairo lines](https://github.com/sanette/bogue-cairo/blob/main/docs/images/lines.png)

## Interactive circles

Change the number of circles interactively using a Slider widget.

![Slider](https://github.com/sanette/bogue-cairo/blob/main/docs/images/circles_slider.png)

# Documentation

[Here](https://sanette.github.io/bogue-cairo/)
