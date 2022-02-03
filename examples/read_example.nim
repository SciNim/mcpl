## This file is a direct port of the C example
## `rawexample_readmcpl.c`

## /////////////////////////////////////////////////////////////////////////////////
##                                                                                //
##  A small standalone example of how to one might read particles from an MCPL    //
##  file into a given programme.                                                  //
##                                                                                //
##  This file can be freely used as per the terms in the LICENSE file.            //
##                                                                                //
##  Written 2015-2016 by Thomas.Kittelmann@esss.se                                //
##                                                                                //
## /////////////////////////////////////////////////////////////////////////////////
import strformat, os
import mcpl

proc main =

  if paramCount() < 1:
    echo "Please supply input filename"
    quit()
  let filename = paramStr(1)

  #Open the file:
  var f = open_file(filename)

  #For fun, access and print a bit of the info found in the header (see mcpl.h for more):

  echo "Opened MCPL file produced with ", hdr_srcname(f)
  for i in 0 ..< hdr_ncomments(f):
    echo "file had comment: ", hdr_comment(f, i.cuint)
  echo "File contains %llu particles ", hdr_nparticles(f)

  #Now, loop over particles and print some info:
  var p: ptr particle_t = read(f)
  while not p.isNil:
    #print some info (see the particle_t struct in mcpl.h for more fields):
    echo &"  found particle with pdgcode {p.pdgcode} and time-stamp {p.time} ms with weight {p.weight} "
    p = read(f)

  close_file(f)

main()
