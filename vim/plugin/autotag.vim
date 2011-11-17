" Increment the number below for a dynamic #include guard
let s:autotag_vim_version=1

if exists("g:autotag_vim_version_sourced")
   if s:autotag_vim_version == g:autotag_vim_version_sourced
      finish
   endif
endif

let g:autotag_vim_version_sourced=s:autotag_vim_version

" This file supplies automatic tag regeneration when saving files
" There's a problem with ctags when run with -a (append)
" ctags doesn't remove entries for the supplied source file that no longer exist
" so this script (implemented in python) finds a tags file for the file vim has
" just saved, removes all entries for that source file and *then* runs ctags -a

if has("python")

python << EEOOFF
import os
import string
import os.path
import fileinput
import sys
import vim
import time

# Just in case the ViM build you're using doesn't have subprocess
if sys.version < '2.4':
   def do_cmd(cmd, cwd):
      old_cwd=os.getcwd()
      os.chdir(cwd)
      (ch_in, ch_out) = os.popen2(cmd)
      for line in ch_out:
         pass
      os.chdir(old_cwd)

   import traceback
   def format_exc():
      return ''.join(traceback.format_exception(*list(sys.exc_info())))

else:
   import subprocess
   def do_cmd(cmd, cwd):
      p = subprocess.Popen(cmd, shell=True, stdout=None, stderr=None, cwd=cwd)

   from traceback import format_exc

def echo(str):
   str=str.replace('\\', '\\\\')
   str=str.replace('"', "'")
   vim.command("redraw | echo \"%s\"" % str)

def diag(verbosity, threshold, msg, args = None):
   if msg and args:
      msg = msg % args
   if verbosity >= threshold:
      echo(msg)

def goodTag(line, excluded):
   if line[0] == '!':
      return True
   else:
      f = string.split(line, '\t')
      if len(f) > 3 and not f[1] in excluded:
         return True
   return False

class AutoTag:
   __maxTagsFileSize = 1024 * 1024 * 7
   __threshold = 1

   def __init__(self):
      self.tags = {}
      self.excludesuffix = [ "." + s for s in vim.eval("g:autotagExcludeSuffixes").split(".") ]
      verbosity = long(vim.eval("g:autotagVerbosityLevel"))
      self.verbosity = verbosity if verbosity > 0 else 0
      self.sep_used_by_ctags = '/'
      self.ctags_cmd = vim.eval("g:autotagCtagsCmd")
      self.tags_file = str(vim.eval("g:autotagTagsFile"))
      self.count = 0

   def findTagFile(self, source):
      self.__diag('source = "%s"' % (source, ))
      ( drive, file ) = os.path.splitdrive(source)
      while file:
         file = os.path.dirname(file)
         #self.__diag('drive = "%s", file = "%s"' % (drive, file))
         tagsFile = os.path.join(drive, file, self.tags_file)
         #self.__diag('tagsFile "%s"' % tagsFile)
         if os.path.isfile(tagsFile):
            st = os.stat(tagsFile)
            if st:
               size = getattr(st, 'st_size', None)
               if size is None:
                  self.__diag("Could not stat tags file %s" % tagsFile)
                  return None
               if AutoTag.__maxTagsFileSize and size > AutoTag.__maxTagsFileSize:
                  self.__diag("Ignoring too big tags file %s" % tagsFile)
                  return None
            return tagsFile
         elif not file or file == os.sep or file == "//" or file == "\\\\":
            #self.__diag('bail (file = "%s")' % (file, ))
            return None
      return None

   def addSource(self, source):
      if not source:
         self.__diag('No source')
         return
      if os.path.basename(source) == self.tags_file:
         self.__diag("Ignoring tags file %s" % (self.tags_file,))
         return
      (base, suff) = os.path.splitext(source)
      if suff in self.excludesuffix:
         self.__diag("Ignoring excluded suffix %s for file %s" % (source, suff))
         return
      tagsFile = self.findTagFile(source)
      if tagsFile:
         relativeSource = source[len(os.path.dirname(tagsFile)):]
         if relativeSource[0] == os.sep:
            relativeSource = relativeSource[1:]
         if os.sep != self.sep_used_by_ctags:
            relativeSource = string.replace(relativeSource, os.sep, self.sep_used_by_ctags)
         if self.tags.has_key(tagsFile):
            self.tags[tagsFile].append(relativeSource)
         else:
            self.tags[tagsFile] = [ relativeSource ]

   def stripTags(self, tagsFile, sources):
      self.__diag("Stripping tags for %s from tags file %s", (",".join(sources), tagsFile))
      backup = ".SAFE"
      input = fileinput.FileInput(files=tagsFile, inplace=True, backup=backup)
      try:
         for l in input:
            l = l.strip()
            if goodTag(l, sources):
               print l
      finally:
         input.close()
         try:
            os.unlink(tagsFile + backup)
         except StandardError:
            pass

   def updateTagsFile(self, tagsFile, sources):
      tagsDir = os.path.dirname(tagsFile)
      self.stripTags(tagsFile, sources)
      if self.tags_file:
         cmd = "%s -f %s -a " % (self.ctags_cmd, self.tags_file)
      else:
         cmd = "%s -a " % (self.ctags_cmd,)
      for source in sources:
         if os.path.isfile(os.path.join(tagsDir, source)):
            cmd += " '%s'" % source
      self.__diag("%s: %s", (tagsDir, cmd))
      do_cmd(cmd, tagsDir)

   def rebuildTagFiles(self):
      for (tagsFile, sources) in self.tags.items():
         self.updateTagsFile(tagsFile, sources)

   def __diag(self, msg, args = None):
      diag(self.verbosity, AutoTag.__threshold, msg, args)
EEOOFF

function! AutoTag()
python << EEOOFF
try:
    if long(vim.eval("g:autotagDisabled")) == 0:
        at = AutoTag()
        at.addSource(vim.eval("expand(\"%:p\")"))
        at.rebuildTagFiles()
except:
    diag(1, -1, format_exc())
EEOOFF
    if exists(":TlistUpdate")
        TlistUpdate
    endif
endfunction

if !exists("g:autotagDisabled")
   let g:autotagDisabled=0
endif
if !exists("g:autotagVerbosityLevel")
   let g:autotagVerbosityLevel=0
endif
if !exists("g:autotagExcludeSuffixes")
   let g:autotagExcludeSuffixes="tml.xml.text.txt"
endif
if !exists("g:autotagCtagsCmd")
   let g:autotagCtagsCmd="ctags"
endif
if !exists("g:autotagTagsFile")
   let g:autotagTagsFile="tags"
endif
augroup autotag
   au!
   autocmd BufWritePost,FileWritePost * call AutoTag ()
augroup END

endif " has("python")

" vim:shiftwidth=3:ts=3
