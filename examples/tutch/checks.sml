(* Copyright (C) 2017 Ryan Kavanagh <rkavanagh@cs.cmu.edu>       *)
(* Distributed under the ISC license, see COPYING for details.   *)

(************************************************************)
(* Make sure you put the tutch sources under support/tutch. *)
(************************************************************)

functor ChecksHelper (structure H : HELPER) : CHECKS where type checks = H.checks =
struct

datatype checks = datatype H.checks

(*****************************************************)
(**********       CONFIGURE ME HERE            *******)
(*****************************************************)

val tutchPath = "./support/tutch/bin/tutch"

val thePDF = "hw3.pdf"

val requiredFiles = [ thePDF
		    , "hw3_6a.tut"
		    , "hw3_6b.tut"
		    , "hw3_6c.tut" ]

(* Compile tutch *)
(* Surely one should be able to call CM.make or something... *)
fun compileTutch () =
  case H.runCmd "make -C ./support/tutch > /dev/null"
   of 0 => ()
    | _ => (H.abortWithMessage o H.stringsInBox)
	       [ "Unable to compile tutch."
	       , "Contact course staff." ]

(* Runs tutch on requirements file "req" and tutch file "tut". *)
(* Awards maxScore if tutch succeeds, 0 otherwise. *)
fun runTutch req tut maxScore =
  case H.runCmd (tutchPath ^ " -r " ^ req ^ " " ^ (H.joinHandinPath tut))
   of 0 => maxScore
    | _ => let val _ = H.printInBox [ "Tutch thinks something went wrong!"
				    , "Please fix and try again." ]
	   in 0.0 end

(* We first make sure all of the required files exist. *)
(* Then we check that the PDF is a valid PDF. *)
(* Finally, we grade the tutch problems 6a--6c at 2 points each. *)
val checks = [ H.Check ("all files present", fn _ => H.checkFilesExist requiredFiles)
	     , H.Check (thePDF, fn _ => H.checkPDF thePDF)
	     , H.Check ("tutch compile", fn _ => compileTutch ()) ]
	     @ (List.map (fn (n,s) =>
			     H.Problem (n, fn _ => runTutch ("./support/hw3_" ^ n ^ ".req")
							    ("hw3_" ^ n ^ ".tut")
							    s))
			 [("6a", 2.0), ("6b", 2.0), ("6c", 2.0)])

(* Empty scoreboard *)
fun scoreboard _ = NONE

(*****************************************************)
(**********        END CONFIGURATION           *******)
(*****************************************************)

end
