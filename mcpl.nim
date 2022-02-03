## *********************************************************************************
##
##   Monte Carlo Particle Lists : MCPL
##
##   Utilities for reading and writing .mcpl files: A binary format with lists of
##   particle state information, for interchanging and reshooting events between
##   various Monte Carlo simulation applications.
##
##   Find more information and updates at https://mctools.github.io/mcpl/
##
##   This file can be freely used as per the terms in the LICENSE file.
##
##   Written by Thomas Kittelmann, 2015-2017.
##
## *********************************************************************************


when defined(windows):
  const
    libSuffix = ".dll"
    libPrefix = ""
elif defined(macosx):
  const
    libSuffix = ".dylib"
    libPrefix = "lib"
else:
  const
    libSuffix = ".so(||.15)"
    libPrefix = "lib"
const
  mcpl {.strdefine.} = "mcpl"
  ## TODO: allow more options
  libmcpl* = libPrefix & mcpl & libSuffix

const
  MCPL_VERSION_MAJOR* = 1
  MCPL_VERSION_MINOR* = 3
  MCPL_VERSION_PATCH* = 2
  MCPL_VERSION* = 10302
  MCPL_VERSION_STR* = "1.3.2"
  MCPL_FORMATVERSION* = 3

## *******
##  Types
## *******

##  The data structure representing a particle (note that persistification of
##  polarisation and userflags must be explicitly enabled when writing .mcpl
##  files, or they will simply contain zeroes when the file is read):

type
  particle_t* {.bycopy.} = object
    ekin*: cdouble             ##  kinetic energy [MeV]
    polarisation*: array[3, cdouble] ##  polarisation vector
    position*: array[3, cdouble] ##  position [cm]
    direction*: array[3, cdouble] ##  momentum direction (unit vector)
    time*: cdouble             ##  time-stamp [millisecond]
    weight*: cdouble           ##  weight or intensity
    pdgcode*: cint          ##  MC particle number from the Particle Data Group (2112=neutron, 22=gamma, ...)
    userflags*: cuint       ##  User flags (if used, the file header should probably contain information about how).

  file_t* {.bycopy.} = object
    internal*: pointer


##  file-object used while reading .mcpl

type
  outfile_t* {.bycopy.} = object
    internal*: pointer


##  file-object used while writing .mcpl
## **************************
##  Creating new .mcpl files
## **************************
##  Instantiate new file object (will also open and override specified file)

proc create_outfile*(filename: cstring): outfile_t {.importc: "mcpl_create_outfile",
    dynlib: libmcpl.}
proc outfile_filename*(a1: outfile_t): cstring {.importc: "mcpl_outfile_filename",
    dynlib: libmcpl.}
##  filename being written to (might have had .mcpl appended)
##  Optionally set global options or add info to the header:

proc hdr_set_srcname*(a1: outfile_t; a2: cstring) {.importc: "mcpl_hdr_set_srcname",
    dynlib: libmcpl.}
##  Name of the generating application

proc hdr_add_comment*(a1: outfile_t; a2: cstring) {.importc: "mcpl_hdr_add_comment",
    dynlib: libmcpl.}
##  Add one or more human-readable comments

proc hdr_add_data*(a1: outfile_t; key: cstring; ldata: cuint; data: cstring) {.
    importc: "mcpl_hdr_add_data", dynlib: libmcpl.}
##  add binary blobs by key

proc enable_userflags*(a1: outfile_t) {.importc: "mcpl_enable_userflags",
                                     dynlib: libmcpl.}
##  to write the "userflags" info

proc enable_polarisation*(a1: outfile_t) {.importc: "mcpl_enable_polarisation",
                                        dynlib: libmcpl.}
##  to write the "polarisation" info

proc enable_doubleprec*(a1: outfile_t) {.importc: "mcpl_enable_doubleprec",
                                      dynlib: libmcpl.}
##  use double precision FP numbers in storage

proc enable_universal_pdgcode*(a1: outfile_t; pdgcode: cint) {.
    importc: "mcpl_enable_universal_pdgcode", dynlib: libmcpl.}
##  All particles are of the same type

proc enable_universal_weight*(a1: outfile_t; w: cdouble) {.
    importc: "mcpl_enable_universal_weight", dynlib: libmcpl.}
##  All particles have the same weight
##  Optionally (but rarely skipped) add particles, by updating the info in
##  and then passing in a pointer to an mcpl_particle_t instance:

proc add_particle*(a1: outfile_t; a2: ptr particle_t) {.importc: "mcpl_add_particle",
    dynlib: libmcpl.}
##  Finally, always remember to close the file:

proc close_outfile*(a1: outfile_t) {.importc: "mcpl_close_outfile", dynlib: libmcpl.}
##  Alternatively close with (will call mcpl_gzip_file after close).
##  Returns non-zero if gzipping was succesful:

proc closeandgzip_outfile*(a1: outfile_t): cint {.
    importc: "mcpl_closeandgzip_outfile", dynlib: libmcpl.}
##  Convenience function which returns a pointer to a nulled-out particle
##      struct which can be used to edit and pass to mcpl_add_particle. It can be
##      reused and will be automatically free'd when the file is closed:

proc get_empty_particle*(a1: outfile_t): ptr particle_t {.
    importc: "mcpl_get_empty_particle", dynlib: libmcpl.}
## *********************
##  Reading .mcpl files
## *********************
##  Open file and load header information into memory, skip to the first (if
##  any) particle in the list:

proc open_file*(filename: cstring): file_t {.importc: "mcpl_open_file",
    dynlib: libmcpl.}
##  Access header data:

proc hdr_version*(a1: file_t): cuint {.importc: "mcpl_hdr_version", dynlib: libmcpl.}
##  file format version (not the same as MCPL_VERSION)

proc hdr_nparticles*(a1: file_t): culonglong {.importc: "mcpl_hdr_nparticles",
    dynlib: libmcpl.}
##  number of particles stored in file

proc hdr_srcname*(a1: file_t): cstring {.importc: "mcpl_hdr_srcname", dynlib: libmcpl.}
##  Name of the generating application

proc hdr_ncomments*(a1: file_t): cuint {.importc: "mcpl_hdr_ncomments",
                                     dynlib: libmcpl.}
##  number of comments stored in file

proc hdr_comment*(a1: file_t; icomment: cuint): cstring {.importc: "mcpl_hdr_comment",
    dynlib: libmcpl.}
##  access i'th comment

proc hdr_nblobs*(a1: file_t): cint {.importc: "mcpl_hdr_nblobs", dynlib: libmcpl.}
proc hdr_blobkeys*(a1: file_t): cstringArray {.importc: "mcpl_hdr_blobkeys",
    dynlib: libmcpl.}
##  returns 0 if there are no keys

proc hdr_blob*(a1: file_t; key: cstring; ldata: ptr cuint; data: cstringArray): cint {.
    importc: "mcpl_hdr_blob", dynlib: libmcpl.}
##  access data (returns 0 if key doesn't exist)

proc hdr_has_userflags*(a1: file_t): cint {.importc: "mcpl_hdr_has_userflags",
                                        dynlib: libmcpl.}
proc hdr_has_polarisation*(a1: file_t): cint {.importc: "mcpl_hdr_has_polarisation",
    dynlib: libmcpl.}
proc hdr_has_doubleprec*(a1: file_t): cint {.importc: "mcpl_hdr_has_doubleprec",
    dynlib: libmcpl.}
proc hdr_header_size*(a1: file_t): culonglong {.importc: "mcpl_hdr_header_size",
    dynlib: libmcpl.}
##  bytes consumed by header (uncompressed)

proc hdr_particle_size*(a1: file_t): cint {.importc: "mcpl_hdr_particle_size",
                                        dynlib: libmcpl.}
##  bytes per particle (uncompressed)

proc hdr_universal_pdgcode*(a1: file_t): cint {.
    importc: "mcpl_hdr_universal_pdgcode", dynlib: libmcpl.}
##  returns 0 in case of per-particle pdgcode

proc hdr_universal_weight*(a1: file_t): cdouble {.
    importc: "mcpl_hdr_universal_weight", dynlib: libmcpl.}
##  returns 0.0 in case of per-particle weights

proc hdr_little_endian*(a1: file_t): cint {.importc: "mcpl_hdr_little_endian",
                                        dynlib: libmcpl.}
##  Request pointer to particle at current location and skip forward to the next
##  particle. Return value will be null in case there was no particle at the
##  current location (normally due to end-of-file):

proc read*(a1: file_t): ptr particle_t {.importc: "mcpl_read", dynlib: libmcpl.}
##  Seek and skip in particles (returns 0 when there is no particle at the new position):

proc skipforward*(a1: file_t; n: culonglong): cint {.importc: "mcpl_skipforward",
    dynlib: libmcpl.}
proc rewind*(a1: file_t): cint {.importc: "mcpl_rewind", dynlib: libmcpl.}
proc seek*(a1: file_t; ipos: culonglong): cint {.importc: "mcpl_seek", dynlib: libmcpl.}
proc currentposition*(a1: file_t): culonglong {.importc: "mcpl_currentposition",
    dynlib: libmcpl.}
##  Deallocate memory and release file-handle with:

proc close_file*(a1: file_t) {.importc: "mcpl_close_file", dynlib: libmcpl.}
## *********************************
##  Other operations on .mcpl files
## *********************************
##  Dump information about the file to std-output:
##    parts : 0 -> header+particle list, 1 -> just header, 2 -> just particle list.
##    nlimit: maximum number of particles to list (0 for unlimited)
##    nskip : index of first particle in the file to list.

proc dump*(file: cstring; parts: cint; nskip: culonglong; nlimit: culonglong) {.
    importc: "mcpl_dump", dynlib: libmcpl.}
##  Merge contents of a list of files by concatenating all particle contents into a
##  new file, file_output. This results in an error unless all meta-data and settings
##  in the files are identical. Also fails if file_output already exists. Note that
##  the return value is a handle to the output file which has not yet been closed:

proc merge_files*(file_output: cstring; nfiles: cuint; files: cstringArray): outfile_t {.
    importc: "mcpl_merge_files", dynlib: libmcpl.}
##  Test if files could be merged by mcpl_merge_files:

proc can_merge*(file1: cstring; file2: cstring): cint {.importc: "mcpl_can_merge",
    dynlib: libmcpl.}
##  Similar to mcpl_merge_files, but merges two files by appending all particles in
##  file2 to the list in file1 (thus file1 grows while file2 stays untouched).
##  Note that this requires similar version of the MCPL format of the two files, in
##  addition to the other checks in mcpl_can_merge().
##  Careful usage of this function can be more efficient than mcpl_merge_files.

proc merge_inplace*(file1: cstring; file2: cstring) {.importc: "mcpl_merge_inplace",
    dynlib: libmcpl.}
##  Attempt to merge incompatible files, by throwing away meta-data and otherwise
##  selecting a configuration which is suitable to contain the data of all files.
##  Userflags will be discarded unless keep_userflags=1.
##  If called with compatible files, the code will fall back to calling the usual
##  mcpl_merge_files function instead.

proc forcemerge_files*(file_output: cstring; nfiles: cuint; files: cstringArray;
                      keep_userflags: cint): outfile_t {.
    importc: "mcpl_forcemerge_files", dynlib: libmcpl.}
##  Attempt to fix number of particles in the header of a file which was never
##  properly closed:

proc repair*(file1: cstring) {.importc: "mcpl_repair", dynlib: libmcpl.}
##  For easily creating a standard mcpl-tool cmdline application:

proc tool*(argc: cint; argv: cstringArray): cint {.importc: "mcpl_tool", dynlib: libmcpl.}
##  Attempt to run gzip on a file (does not require MCPL_HASZLIB on unix)
##  Returns non-zero if gzipping was succesful.

proc gzip_file*(filename: cstring): cint {.importc: "mcpl_gzip_file", dynlib: libmcpl.}
##  Convenience function which transfers all settings, blobs and comments to
##  target. Intended to make it easy to filter files via custom C code.

proc transfer_metadata*(source: file_t; target: outfile_t) {.
    importc: "mcpl_transfer_metadata", dynlib: libmcpl.}
##  Function which can be used when transferring particles from one MCPL file
##  to another. A particle must have been already read from the source file
##  with a call to mcpl_read(..). This function will transfer the packed par-
##  ticle data exactly when possible (using mcpl_add_particle can in principle
##  introduce tiny numerical uncertainties due to the internal unpacking and
##  repacking of direction vectors involved):

proc transfer_last_read_particle*(source: file_t; target: outfile_t) {.
    importc: "mcpl_transfer_last_read_particle", dynlib: libmcpl.}
## ****************
##  Error handling
## ****************
##  Override the error handler which will get called with the error
##  description. If no handler is set, errors will get printed to stdout and the
##  process terminated. An error handler should not return to the calling code.

proc set_error_handler*(handler: proc (a1: cstring)) {.
    importc: "mcpl_set_error_handler", dynlib: libmcpl.}
## ********************
##  Obsolete functions
## ********************
##  Functions kept for backwards compatibility. They keep working for now, but
##  usage will result in a warning printed to stdout, notifying users to update
##  their code.

proc merge*(a1: cstring; a2: cstring) {.importc: "mcpl_merge", dynlib: libmcpl.}
##  Obsolete name for mcpl_merge_inplace

proc gzip_file_rc*(filename: cstring): cint {.importc: "mcpl_gzip_file_rc",
    dynlib: libmcpl.}
##  Obsolete name for mcpl_gzip_file

proc closeandgzip_outfile_rc*(a1: outfile_t): cint {.
    importc: "mcpl_closeandgzip_outfile_rc", dynlib: libmcpl.}
##  Obsolete name for mcpl_closeandgzip_outfile_rc

proc hdr_universel_pdgcode*(a1: file_t): cint {.
    importc: "mcpl_hdr_universel_pdgcode", dynlib: libmcpl.}
##  Obsolete name for mcpl_hdr_universal_pdgcode
