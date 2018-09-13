(* Copyright (C) 2017 Ryan Kavanagh <rkavanagh@cs.cmu.edu>       *)
(* Distributed under the ISC license, see COPYING for details.   *)

signature CHECKS =
sig
    (* checks are either:                                         *)
    (* Check (name, f):                                           *)
    (*   f : checks some property, and can catastrophically abort *)
    (*   or raise some exception if something is not satisfied.   *)
    (*   Useful for sanity checks like: do all desired files      *)
    (*   exist?                                                   *)
    (* Problem (name, f):                                         *)
    (*   name : must be the same name as the autolab problem      *)
    (*         that is being graded.                              *)
    (*   f : returns an integer, which is the score awarded for   *)
    (*       problem "name".                                      *)
    datatype checks = Check   of string * (unit -> unit)
		    | Problem of string * (unit -> real)

    val checks : checks list

    val scoreboard : (string * real) list -> int list option
end
