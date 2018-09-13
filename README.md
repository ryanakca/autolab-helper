This is a skeleton for a checkscript for autolab. In order to make
this happen there are a small battery of SML scripts.

New in f17 for 15-317: we introduce a directory per assignment
containing the autolab checks, rather than using a single "src"
directory that gets modified every time we have a new assignment.

The central one is `checks.sml`. In it, you can describe a sequence of
checks to perform (not necessarily related to any given problem).  You
can also describe a series of Autolab problems to grade. These checks
and problems belong in the variable `checks`. See the file for
examples and further documentation. When writing your checks, you
should assume that a given student's files are in the subdirectory
`./handin` (relative to the file `main.sml`) during check execution.

This file is loaded by the file `main.sml`. This file runs the tests
described in the the `checks` variable from `checks.sml` and outputs a
correctly-formatted [Autolab score string]. You should never need to
edit main.sml.

The file `helper.sml` provides a variety of helper functions for
grading, described

In order to create an autolab test for homework NN, we recommend you
do the following:

 - Copy `./skel/*` to `./NN/`
 - If you want to check your students submitted the correct files, use
   the checkFilesExist check described in the skeleton `checks.sml`.
   It will check that each file in the list exists under the directory
   `./handin`, and will abort the grading if it is missing.
 - To keep things organised, put various utilities, etc., you need to
   grade assignments under `./NN/support/`.
 - If you're doing anything really really funky, update the
   `autograde` target in `./NN/Makefile` . It **must** generate the
   file `./autograde.tar` containing all files you require for your
   checks. The skeleton Makefile at the time of this writing simply
   creates a tarball with the contents of `./NN/*` in the top level,
   and dereferences any symlinks.
 - Test your scripts using `./NN/test_checks.sh` (see below).
 - Run `make NN-autograde` to generate `autograder.tar`.
 - Upload `./autograder.tar` and `autograde-Makefile` to Autolab.

And you're all set.

If you want to automatically test your `./NN/checks.sml` against some
submissions to make sure the output scores are reasonable, the script
`./NN/test_checks.sh` will look in the directory `./NN/test_handins/`
for test submissions, and will run your check scripts against them.
See `./NN/test_handins/README` for more details.

I know of no *clean* way to abort the autograder without updating any
scores. The semantically cleanest way is to return an empty scores
dictionary in the autoscore. However, at the time of this writing,
Autolab complains with an error when we do so. This is, in my opinion,
a bug, and should be fixed by this [pull request].

[Autolab score string]: https://autolab.github.io/docs/lab/
[pull request]: https://github.com/autolab/Autolab/pull/895
