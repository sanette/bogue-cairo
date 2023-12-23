(** Bogue_cairo

    {e Want to add the power of Cairo's drawing functions to your GUI
    application?}

    [Bogue_cairo] is an add-on library for the
    {{:https://sanette.github.io/bogue/Principles.html}Bogue} GUI library,
    enabling the use of
    {{:https://chris00.github.io/ocaml-cairo/doc/cairo2/Cairo/}Cairo drawing
    functions} in Bogue's
    {{:https://sanette.github.io/bogue/Bogue.Sdl_area.html}Sdl_area}'s.

@author Vũ Ngọc San

@see <https://github.com/sanette/bogue-cairo> the source code on github

*)

module Cairo_area : sig
  type t
  (** A Cairo area is a
      {{:https://chris00.github.io/ocaml-cairo/doc/cairo2/Cairo/#cairo_t}Cairo
      context} married to a Bogue
      {{:https://sanette.github.io/bogue/Bogue.Sdl_area.html}Sdl_area}. Both can
      be used at the same time (see {!flush}). *)

  (** {2 Creating the Cairo area} *)

  val of_sdl_area : Bogue.Sdl_area.t -> t
  (** Create a Cairo area on top of an existing SDL area. *)

  val create_with_widget :
    w:int -> h:int -> ?style:Bogue.Style.t -> unit -> t * Bogue.Widget.t
  (** Create a Cairo area from scratch and also return a Bogue widget containing
     the (underlying) SDL area. The interpretation of the arguments is the same
     as for an SDL area: width, height, and background style. *)

  (** {2 Using the Cairo area} *)

  val init : t -> unit
  (** Initializing the Cairo area is compulsory before adding any drawing
     commands. *)

  val add : t -> (Cairo.context -> unit) -> unit
  (** [add cairo f] adds the command [f] to the Cairo command queue (which is
      actually shared with the SDL command queue of the underlying SDL area).
      The difference is that a Cairo_area command must take as its argument a
      Cairo context, while an Sdl_area command takes an SDL renderer. For
      instance:
      {[add cairo (fun cr -> Cairo.move_to cr 0. 0.)]}

      As for Sdl_area, the command should be fast, or else it will block the rest of
      BOGUE's interface. *)

  val flush : t -> unit
  (** Insert a Cairo flush command in the command queue. This is compulsory at
      least at the end of your Cairo commands if you want to see something
      onscreen. If you don't use the Cairo context anymore, use {!finalize}
      instead. If you mix SDL commands and Cairo commands, note that Cairo
      drawings will appear on the SDL area only at the [flush] invocation. *)

  val finalize : t -> unit
  (** Flush and free the Cairo context. It is not usable anymore, unless you
      call {!init} on it again. *)

  val clear : t -> unit
  (** Clear the whole area (SDL+Cairo) (but not the background). *)

  val full_session : Bogue.Sdl_area.t -> (Cairo.context -> unit) -> unit
  (** Shortcut for small Cairo sessions: [full_session area f] will create a
     cairo context with [of_sdl_area area] and then
     [init cairo; add cairo f; finalize cairo]. *)

  (** {2 Drawing functions and utilities}

      Shortcuts to existing Cairo commands, but with the same syntax as Bogue's
      built-in drawing functions. *)

  val drawing_size : t -> int * int
  (** Size in physical pixels of the drawing area. *)

  val set_color : Cairo.context -> Bogue.Draw.color -> unit
  (** Set the drawing color for subsequent Cairo drawing functions. (But not for
     SDL functions.) *)

  val draw_line :
    t -> ?color:Bogue.Draw.color -> thick:int -> int * int -> int * int -> unit
  (** [draw_line cairo ~color ~thick (x1, y1) (x2, y2)] draws a line of given
      [color] and [thick]ness from point [(x1, y1)] to point [(x2, y2)]. *)

  val draw_rectangle :
    t ->
    ?color:Bogue.Draw.color ->
    thick:int ->
    w:int ->
    h:int ->
    int * int ->
    unit
  (** [draw_rectangle cairo ~color ~thick ~w ~h (x0, y0)] draws a rectangle of the
      given line [thick]ness and [color] {e inside} the box of top-left coordinates
      [(x0, y0)], width [w] and height [h]. *)

  val draw_circle :
    t -> ?color:Bogue.Draw.color -> thick:int -> radius:int -> int * int -> unit
  (** [draw_circle cairo ~color ~thick ~radius (x0, y0)] draws a circle of the given
      line [thick]ness and [color] {e inside} the disc of center coordinates
      [(x0, y0)] and given [radius]. *)
end

(** {3 Example}

If you have installed [Bogue], you may run [boguex 50] to see a demo of drawing
circles using the native Bogue circle primitive. Here is an alternative version,
using Cairo's circles, which is twice as fast.

{[
open Bogue
open Bogue_cairo

let circles () =
  let cairo, a = Cairo_area.create_with_widget ~w:500 ~h:200 () in
  let w,h = Cairo_area.drawing_size cairo in
  Printf.sprintf "Cairo area Physical pixel size: (w=%i, h=%i)" w h
  |> print_endline;
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

  let layout = Layout.resident ~name:"Bogue-Cairo circles" a in
  Bogue.(run (of_layout layout))

let () =
  circles ()
]}

 {%html:<div class="figure"><img src="images/cairo-circles.png"></div>%}
*)
