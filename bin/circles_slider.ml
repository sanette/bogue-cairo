(* This file is part of Bogue-cairo *)

(* Select the number of circles you want to draw using a slider! *)
(* https://github.com/sanette/bogue-cairo *)
(* by San Vu Ngoc *)

(* Run this demo with [dune exec ./circles_slider.exe] *)

open Bogue
module W = Widget
module L = Layout
open Bogue_cairo

let random_circle ~w ~h cairo =
  let radius = Random.int 100 + 1 in
  let thick = Random.int radius in
  let color = RGBA.random_color () in
  let x = Random.int w in
  let y = Random.int h in
  Cairo_area.draw_circle cairo ~color ~thick ~radius (x, y)

let update cairo n =
  Cairo_area.clear_queue cairo;
  Cairo_area.init cairo;
  let w, h = Cairo_area.drawing_size cairo in
  for _ = 1 to n do
    random_circle ~w ~h cairo
  done;
  Cairo_area.flush cairo

let circles () =
  let n0 = ref 500 in
  let cairo, a = Cairo_area.create_with_widget ~w:500 ~h:200 () in
  let label = W.label "Number of circles:" in
  let number = W.label (string_of_int !n0) in

  let action n =
    if n <> !n0 then (
      update cairo n;
      W.set_text number (string_of_int n);
      n0 := n)
  in

  let slider =
    W.slider_with_action ~step:1 ~action ~value:!n0 999
    |> L.resident ~background:(L.color_bg RGBA.(transp RGB.green))
  in
  update cairo !n0;

  let layout =
    L.tower ~name:"Bogue-Cairo slider"
      [
        L.flat ~align:Draw.Center [ slider; L.flat_of_w [ label; number ] ];
        L.resident a;
      ]
  in
  Bogue.(run (of_layout layout))

let () = circles ()
