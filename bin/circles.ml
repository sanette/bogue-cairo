open Bogue
module W = Widget
module L = Layout
open Bogue_cairo

let pr = Printf.printf

(* compare BOGUE example 50 *)
let circles () =
  let cairo, a = Cairo_area.create_with_widget ~w:500 ~h:200 () in
  let w,h = Cairo_area.drawing_size cairo in
  pr "w=%i, h=%i\n" w h;
  let random_circle () =
    let radius = Random.int 100 + 1 in
    let thick = Random.int radius in
    let color = Draw.random_color () in
    let x = Random.int w in
    let y = Random.int h in
    Cairo_area.draw_circle cairo ~color ~thick ~radius (x, y)
  in
  Cairo_area.init cairo;
  for _ = 0 to 500 do
    random_circle ()
  done;
  Cairo_area.flush cairo;
  Cairo_area.finalize cairo;

  let layout = L.resident ~name:"Bogue-Cairo circles" a in
  Bogue.(run (make [] [layout]))

let () =
  circles ()
