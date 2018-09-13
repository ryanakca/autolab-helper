(* Copyright (C) 2017 Ryan Kavanagh <rkavanagh@cs.cmu.edu>       *)
(* Distributed under the ISC license, see COPYING for details.   *)

signature HELPER =
sig
    datatype checks = Check   of string * (unit -> unit)
		    | Problem of string * (unit -> real)

    (* Path to the directory under which we can find a student's *)
    (* submitted files. *)
    val handinPath : string

    (* Takes in the name of a file submitted by a student *)
    (* and joins it with handinPath. *)
    val joinHandinPath : string -> string

    (* Removes handinPath from a path if it prefixes it. *)
    val stripHandinPath : string -> string

    (* Takes in a list of filenames, and checks if those files *)
    (* exist in the handinPath directory. *)
    (* Aborts catastrophically if a file is missing. *)
    val checkFilesExist : string list -> unit

    (* Uses ghostscript to check if the student submitted a valid *)
    (* PDF (or an empty file in its place). Aborts catastrophically *)
    (* if missing. *)
    val checkPDF : string -> unit

    (* Runs a series of checks and then outputs a list of *)
    (* (problem name, score) tuples *)
    val runChecks : checks list -> (string * real) list

    (* Produces an AutoLab JSON score string from a scores list *)
    (* and optional scoreboard *)
    val scoresToString : (string * real) list * int list option -> string

    (* Puts a list of strings in a box for printing. *)
    val stringsInBox : string list -> string list

    (* Prints a list of strings in a box. *)
    val printInBox : string list -> unit

    (* Prints a string followed by newline. *)
    val printLn : string -> unit

    (* printLns a list of strings, then the empty score, *)
    (* then exits. Useful when you need to abort early. *)
    val abortWithMessage : string list -> 'a

    (* Prints a command and then runs it, returning the exit status *)
    val runCmd : string -> OS.Process.status

    (* Runs a command (with argument list) using Posix.Process.execp. *)
    (* Return the program's output as a string, along with its exit status. *)
    val execpOutput : string * string list -> string * Posix.Process.exit_status

    (* Takes a regex in awk format, and a string, and checks if *)
    (* the regex matches the string *)
    val matchesAwkRegex : string * string -> bool
end
