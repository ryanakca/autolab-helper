(* Copyright (C) 2017 Ryan Kavanagh <rkavanagh@cs.cmu.edu>       *)
(* Distributed under the ISC license, see COPYING for details.   *)

functor ChecksHelper (structure H : HELPER) : CHECKS where type checks = H.checks =
struct

datatype checks = datatype H.checks

(*****************************************************)
(**********       CONFIGURE ME HERE            *******)
(*****************************************************)

val requiredFiles = ["hw0.pdf", "ex1.tut", "ex2.tut"]

(* Returns the score l + h *)
fun check1 l h : real = l + h

(* Is evil and always gives the student 0.0 *)
fun check2 () = 0.0

(* We first make sure all of the required files exist. *)
(* We then grade AutoLab problem "ex1" using the test1 function. *)
(* Finally, we grade AutoLab problem "ex2". *)
val checks = [ H.Check ("all files present", fn _ => H.checkFilesExist requiredFiles)
	     , H.Check ("hw0.pdf", fn _ => H.checkPDF "hw0.pdf")
	     , H.Problem ("ex1", fn _ => check1 3.0 4.0)
	     , H.Problem ("ex2", fn _ => check2 ()) ]

(* Empty scoreboard *)
fun scoreboard _ = NONE

(*****************************************************)
(**********        END CONFIGURATION           *******)
(*****************************************************)

end
