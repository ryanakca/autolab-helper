(* Copyright (C) 2017-2018 Ryan Kavanagh <rkavanagh@cs.cmu.edu>   *)
(* Distributed under the ISC license, see COPYING for details.    *)

(* This is a hypothetical assignment where students have to       *)
(* implement addition. There are two Autolab problems testing     *)
(* their implementation on "easy" and "hard" pairs of input.      *)
(* The scoreboard just keeps track of how many bonuses problems   *)
(* their implementation solves.                                   *)
(* Because addition can be very lengthy, we timeout the execution *)
(* after a fixed amount of time.                                  *)

functor ChecksHelper (structure H : HELPER) : CHECKS where type checks = H.checks =
struct

datatype checks = datatype H.checks

(*****************************************************)
(**********       CONFIGURE ME HERE            *******)
(*****************************************************)

structure Student : ADDER = Adder

(* Run function f with arguments a with timeout of n seconds. *)
fun try n f a = Timeout.runWithTimeout (Time.fromSeconds n) f a

(* test data is of the form *)
(* ("autolab exercise name", maxScore, [(input,expected),...]) *)
val testSums = [("easy", 4, [((1,1),2), ((1,2),3), ((2,2),4), ((3,5),8)]),
		("hard", 8, [((152,203),355), ((1212,2121),3333)])]

(* Bonus problems that get used for score board *)
val bonusSums = [((10,~10),0)]
(* Pretty print problem input *)
fun inputToString (x,y) = (Int.toString x) ^ " + " ^ (Int.toString y)

(* Compare student output to expected output with a timeout, and *)
(* compute the % of correct answers. *)
fun compare tests =
  let fun c (input,expected) =
	let val testStr = inputToString input in
	    case try 10 Student.add input of
		(* No timeout *)
		SOME b => if b = expected then
			      ( H.printLn ("Passed: " ^ testStr)
			      ; (1, 0))
			  else
			      ( H.printLn ("Failed: " ^ testStr)
			      ; H.printLn ("        Expected "
					   ^ (Int.toString expected)
					   ^ " but got " ^ (Int.toString b))
			      ; (0, 1) )
	      | NONE => ( H.printLn ("Timed out after 10s on " ^ testStr)
			; (0, 1))
	end
      fun addp (a, b) (c, d) = (a + c, b + d)
      val (same,diff) = List.foldl (fn (p,acc) => addp (c p) acc)
				   (0, 0)
				   tests
  in real same / real (same + diff) end

val checks = List.map (fn (name,max,tests) =>
			  H.Problem (name, fn _ => real max * compare tests))
		      testSums

fun scoreboard score =
  ( H.printLn "Checking bonuses..."
  ; SOME [List.foldl
	      (fn ((p,b),acc) =>
		  if try 2 Student.add p = SOME b then
		      ( H.printLn ("Got bonus " ^ (inputToString p))
		      ; H.printLn ("Well done!")
		      ; acc + 1
		      )
		  else
		      ( H.printLn ("Failed to add bonus " ^ (inputToString p))
		      ; H.printLn ("in under 2 seconds. Skipping.")
		      ; acc
		      )
	      )
	      0
	      bonusSums] )

(*****************************************************)
(**********        END CONFIGURATION           *******)
(*****************************************************)

end
