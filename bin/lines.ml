open Bogue
module W = Widget
module L = Layout
open Bogue_cairo

(* compare BOGUE example 51 *)
let lines () =
  let cairo, a = Cairo_area.create_with_widget ~w:500 ~h:500 () in
  let w, h = Cairo_area.drawing_size cairo in
  let random_line () =
    let thick = Random.int 50 + 1 in
    let color = RGBA.random_color () in
    let x0 = Random.int w in
    let y0 = Random.int h in
    let x1 = Random.int w in
    let y1 = Random.int h in
    Cairo_area.draw_line cairo ~color ~thick (x0, y0) (x1, y1)
  in
  Cairo_area.init cairo;
  for _ = 0 to 200 do
    random_line ()
  done;
  Cairo_area.flush cairo;
  Cairo_area.finalize cairo;

  let layout = L.resident ~name:"Bogue-Cairo lines" a in
  Bogue.(run (make [] [ layout ]))

let () = lines ()
