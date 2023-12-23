(* This file is part of Bogue_cairo.

   It demonstrates how to use Cairo commands in a BOGUE widget,
   and mix them with SDL commands.

   Copyright San Vu Ngoc 2022
*)

open Bogue
module W = Widget
module L = Layout
open Bogue_cairo
open Tsdl

let no_line = Style.mk_line ~width:0 ()

let round_blue_box =
  let open Style in
  let border = mk_border ~radius:25 no_line in
  create ~border ~background:(color_bg Draw.(transp blue)) ()

(* compare BOGUE example 49 *)
let cairo_sdl_mix () =
  let cairo, a =
    Cairo_area.create_with_widget ~w:500 ~h:200 ~style:round_blue_box ()
  in

  (* We draw a diagonal line and a centered thick rectangle, both with Cairo. *)
  let draw cr =
    let w, h = Cairo_area.drawing_size cairo in
    Cairo_area.set_color cr Draw.(opaque blue);
    let open Cairo in
    set_line_width cr 20.;
    rectangle cr
      (float (w / 4) +. 10.)
      (float (h / 4) +. 10.)
      ~w:(float (w / 2) -. 19.)
      ~h:(float (h / 2) -. 19.);
    stroke cr;
    move_to cr 0. 0.;
    set_line_width cr 1.;
    line_to cr (float w) (float h);
    stroke cr
  in

  (* Another diagonal line, but this time with the SDL API. *)
  let sdl_line renderer =
    let w, h = Utils.go (Sdl.get_renderer_output_size renderer) in
    Draw.set_color renderer Draw.(opaque red);
    Utils.go (Sdl.render_draw_line renderer 0 h w 0)
  in

  (* We draw a thick circle with Cairo. *)
  let circle cr =
    let w, h = Cairo_area.drawing_size cairo in
    Cairo_area.set_color cr Draw.(opaque black);
    let thick = 20. in
    let open Cairo in
    set_line_width cr thick;
    arc cr
      (float (3 * w / 4))
      (float (h / 4))
      ~r:(float ((h / 2) + 1) -. (thick /. 2.))
      ~a1:0. ~a2:(2. *. Float.pi);
    Path.close cr;
    stroke cr
  in

  (* Clear button: clears the Cairo area and adds the black circle and the red
     SDL diagonal (which is now on top). *)
  let cb = W.button "Clear some" in
  W.on_click cb ~click:(fun _ ->
      let area = W.get_sdl_area a in
      Cairo_area.clear cairo;
      Cairo_area.full_session area circle;
      Sdl_area.add area sdl_line);

  Cairo_area.init cairo;
  Cairo_area.add cairo circle;
  Cairo_area.add cairo draw;
  Sdl_area.add (W.get_sdl_area a) sdl_line;
  (* Notice that, since it is issued before [finalize], the SDL red line will be
     drawn *before* the Cairo drawing (and hence will appear *below* the
     latter). *)
  Cairo_area.finalize cairo;

  let clear = L.flat ~margins:0 ~align:Draw.Center [ L.resident cb ] in
  Space.full_width clear;

  let layout = L.tower [ L.resident a; clear ] in
  Bogue.(run (make [] [ layout ]))

let () = cairo_sdl_mix ()
