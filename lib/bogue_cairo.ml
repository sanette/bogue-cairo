(* BOGUE-Cairo

   Copyright San Vu Ngoc 2022

   This library is an add-on to BOGUE.
   http://sanette.github.io/bogue/Principles.html
   It enables the use of Cairo's drawing functions in BOGUE's Sdl_area's.
   http://chris00.github.io/ocaml-cairo/doc/cairo2/Cairo/#drawing-operations
*)

open Tsdl
open Bogue

module Cairo_area = struct
  type cairo = {
    data :
      (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t;
    (* [data] can in principle be recovered by [Cairo.Image.get_data8 surface]
       but this has a bug, see https://github.com/Chris00/ocaml-cairo/issues/28
    *)
    target : Sdl.texture;
    stream : Sdl.texture;
    surface : Cairo.Surface.t;
        (* pas nécessaire, on peut faire
           [Cairo.get_target cr]*)
    cr : Cairo.context;
  }

  type t = { area : Sdl_area.t; mutable cairo : cairo option }

  let of_sdl_area area = { area; cairo = None }

  (* return the cairo context and the bogue widget *)
  let create_with_widget ~w ~h ?style () =
    let w = Widget.sdl_area ~w ~h ?style () in
    let area = Widget.get_sdl_area w in
    (of_sdl_area area, w)

  let drawing_size cairo = Sdl_area.drawing_size cairo.area
  let go = Utils.go

  (* Create an SDL texture compatible with Cairo (an SDL streaming texture) *)
  let create_cairo_texture renderer w h =
    let format = Sdl.Pixel.format_argb8888 in
    Sdl.create_texture renderer format Sdl.Texture.access_streaming ~w ~h |> go

  let init_data cairo = Bigarray.Array1.fill cairo.data 0

  (* Copy the Sdl_area texture to the Cairo surface. Not used *)
  let _import_sdl_area_to_cairo renderer cairo =
    (* We have to copy the original target texture onto the new streaming
       texture. SDL_RenderReadPixels is supposed to be very slow,
       https://wiki.libsdl.org/SDL_RenderReadPixels. If you know of a better
       way to do this, please tell! *)
    let save_target = Sdl.get_render_target renderer in
    go (Sdl.set_render_target renderer (Some cairo.target));
    let format = Some Sdl.Pixel.format_argb8888 in
    let pitch = Cairo.Image.get_stride cairo.surface in
    go (Sdl.render_read_pixels renderer None format cairo.data pitch);
    go (Sdl.set_render_target renderer save_target);
    Cairo.Surface.mark_dirty cairo.surface

  let copy_cairo_to_sdl_area renderer cairo =
    let save_target = Sdl.get_render_target renderer in
    Sdl.unlock_texture cairo.stream;
    go (Sdl.set_texture_blend_mode cairo.stream Sdl.Blend.mode_blend);
    go (Sdl.set_render_target renderer (Some cairo.target));
    go (Sdl.render_copy renderer cairo.stream);
    go (Sdl.set_render_target renderer save_target)

  (* [init_cairo] has to be called after the Sdl_area is initialized *)
  let init_cairo c renderer =
    let w, h = Sdl_area.drawing_size c.area in
    let target =
      match Sdl_area.get_texture c.area with
      | None -> failwith "[init_cairo] error: Sdl_area was not initialized."
      | Some t -> t
    in
    assert (
      (w, h)
      =
      let _, _, (w, h) = go (Sdl.query_texture target) in
      (w, h));
    let stream = create_cairo_texture renderer w h in
    let data, stream_pitch =
      go @@ Sdl.lock_texture stream None Bigarray.int8_unsigned
    in
    assert (stream_pitch = 4 * w);
    let surface = Cairo.Image.(create_for_data8 data ARGB32) ~w ~h in
    let cr = Cairo.create surface in
    let cairo = { target; data; stream; surface; cr } in
    init_data cairo;
    c.cairo <- Some cairo

  (*********)

  let init c = Sdl_area.add ~name:"cairo init" c.area (init_cairo c)

  let add c f =
    Sdl_area.add ~name:"cairo" c.area (fun _ ->
        match c.cairo with
        | None ->
            print_endline
              "[Cairo_area.add] error: Cairo context was not initialized."
        | Some cairo -> f cairo.cr)

  let flush c =
    Sdl_area.add ~name:"cairo flush" c.area (fun renderer ->
        match c.cairo with
        | None -> print_endline "Cairo_area: nothing to finalize."
        | Some cairo ->
            Cairo.Surface.flush cairo.surface;
            copy_cairo_to_sdl_area renderer cairo)

  let finalize c =
    flush c;
    Utils.do_option c.cairo (fun cairo -> Cairo.Surface.finish cairo.surface);
    c.cairo <- None

  (* Warning: this executes immediately. If called shortly after the init, then
     the init command is removed and hence never executed.*)
  let clear_queue c =
    (* Utils.do_option c.cairo (fun cairo -> *)
    (*     init_data cairo; *)
    (*     Cairo.Surface.mark_dirty cairo.surface); *)
    Sdl_area.clear c.area

  let full_session area f =
    let c = of_sdl_area area in
    init c;
    add c f;
    finalize c

  (***********)

  let set_color cr color =
    let r, g, b, a = color in
    Cairo.set_source_rgba cr
      (float r /. 255.)
      (float g /. 255.)
      (float b /. 255.)
      (float a /. 255.)

  let draw_rectangle c ?color ~thick ~w ~h (x, y) =
    let x = float (x - (thick / 2)) in
    let y = float (y - (thick / 2)) in
    let w = float (w - thick + 1) in
    let h = float (h - thick + 1) in
    add c (fun cr ->
        let open Cairo in
        Utils.do_option color (fun color -> set_color cr color);
        set_line_width cr (float thick);
        (* TODO scale ? *)
        rectangle cr x y ~w ~h;
        stroke cr)

  let draw_circle c ?color ~thick ~radius (x, y) =
    let r = float (radius - (thick / 2)) in
    add c (fun cr ->
        let open Cairo in
        Utils.do_option color (fun color -> set_color cr color);
        set_line_width cr (float thick);
        arc cr (float x) (float y) ~r ~a1:0. ~a2:(2. *. Float.pi);
        Path.close cr;
        stroke cr)

  let draw_line c ?color ~thick (x1, y1) (x2, y2) =
    add c (fun cr ->
        let open Cairo in
        Utils.do_option color (fun color -> set_color cr color);
        set_line_width cr (float thick);
        move_to cr (float x1) (float y1);
        line_to cr (float x2) (float y2);
        stroke cr)
end
