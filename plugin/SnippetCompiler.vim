
" Note: ALL the dir variable has a tailing \ character
let s:working_DIR       = has('unix') ? glob("~/C_CPP/") : 'D:\work\C_CPP\'
let s:template_cpp      = s:working_DIR . 'Default.cpp'
let s:template_asm32    = s:working_DIR . 'default_32bit.asm'
let s:template_asm64    = s:working_DIR . 'default_64bit.asm'
let s:template_java     = s:working_DIR . 'Default.java'
let s:compile_out       = s:working_DIR . 'compile_output.txt'
let s:pch_compile_out   = s:working_DIR . 'pch_compile_out.txt'
let s:pch_cpp_fname     = s:working_DIR . 'my_precompile_header.cpp'
let s:pch_obj_fname     = s:working_DIR . 'my_precompile_header.obj'
let s:cpp_snippet_fname = s:working_DIR . 'CPP_Snippet.cpp'
let s:asm32_snippet_fname = s:working_DIR . 'asm32_snippet.asm'
let s:asm64_snippet_fname = s:working_DIR . 'asm64_snippet.asm'
let s:java_snippet_fname = substitute(s:cpp_snippet_fname, '\.cpp$', '.java', 'i')
let s:exe_snippet_fname = s:working_DIR . 'CPP_Snippet.exe'
let s:exe_pclint_fname  = has('unix') ? 'flint' : 'D:\work\PC.Lint.v9\lint.bat'
let s:gcc_dir           = has('unix') ? '' : 'D:\work\mingw64\bin\'
"let s:gcc_dir           = has('unix') ? '' : 'P:\MinGW\bin\'
let s:exe_gcc           = s:gcc_dir . ( has('unix') ? 'g++' : 'g++.exe' )
let s:pch_fname         = s:working_DIR . 'FrequentlyUsedHeaders.PCH'
let s:pch_header_fname  = s:working_DIR . 'FrequentlyUsedHeaders.h'
let s:shell_done        = s:working_DIR . 'done.txt'
let s:shell_error       = s:working_DIR . 'VimShellError.txt'
let s:batch_fname       = s:working_DIR . (has('unix') ? 'build_all.sh' : 'build_all.bat')
" Get the output of ":scriptnames" in the scriptnames_output variable.
let s:current_script_dir = expand("<sfile>:p:h") . (has('unix') ? '/' : '\')
let s:current_script_file= expand("<sfile>:p")
let s:my_vim_shell      = s:current_script_dir . 'VimShell.exe'
" The initial LIB,INCLUDE environment variable
let s:origin_PATH       = $PATH
let s:origin_INCLUDE    = $INCLUDE
let s:origin_LIB        = $LIB
let s:origin_LIBPATH    = $LIBPATH

" Comment line to switch between VC2008/VC2010
let s:VS2008_Install_DIR= 'C:\Program Files\Microsoft Visual Studio 9.0\'
let s:VS2010_Install_DIR= 'C:\Program Files (x86)\Microsoft Visual Studio 10.0\'
let s:VS_Install_DIR    = s:VS2010_Install_DIR
let s:cl_full_path      = s:VS_Install_DIR . 'VC\Bin\cl.exe'
let s:cl_x64_full_path  = s:VS_Install_DIR . 'VC\Bin\amd64\cl.exe'
let s:ml_full_path      = s:VS_Install_DIR . 'VC\Bin\ml.exe'
let s:ml64_full_path    = s:VS_Install_DIR . 'VC\Bin\amd64\ml64.exe'
" Intel ICC compiler
let s:ICC_Install_DIR   = 'C:\Program Files\Intel\Compiler\11.1\048\'
let s:ICC_full_path     = s:ICC_Install_DIR . 'bin\ia32\icl.exe'
" boost install dir should be used as $INCLUDE directly, gcc -I"E:\work\boost\boost_1_35_0\" won't work
" but bootst's .H file contains fixed lib hint comment, so must keep \
" as last char, for the gcc case should remove the last \ on-the-way
let s:Boost_root        = 'D:\work\boost\boost_1_35_0\'
let s:Win_SDK_DIR       = 'c:\Program Files (x86)\Microsoft SDKs\Windows\v6.0A\'
let s:Win_SDK_DIR       = 'c:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\'

" // CL_OPTIONS: /I.. /I..\include  
" will be insert before the CPP_Snippet.cpp source file name, after the
" last default compiler option(except /link ... in VC) on the command
" line

if ! filereadable(s:my_vim_shell)
  echohl ErrorMsg 
  echoerr printf("the private vim command shell [%s] not exist!" , s:my_vim_shell)
  echohl Normal
endif

" Description:
"    the script heavily depends on the GCC tools, this
"    function set the appropriate environment variable PATH
"    make g++ works well
function! <SID>:Set_GCC_Working_Env_Variable()
  let $PATH = s:gcc_dir . ';' . s:origin_PATH
endfunction

" Description:
"    the script heavily depends on the Visual C++'s tools, this
"    function set the appropriate environment variable PATH, INCLUDE, LIB to
"    make icl.exe works well
"    Calling it more than once is OK
"    Many of the environment variable must same as vcvars32.bat
function! <SID>:Set_ICC_Working_Env_Variable()
    " Intel icl 11.1 version only works well with VC2008
    call <SID>:Set_VC_Working_Env_Variable(s:VS2008_Install_DIR)
    let $PATH    = s:ICC_Install_DIR . 'bin\ia32;' . $PATH
    let $INCLUDE = s:ICC_Install_DIR . 'include;' . $INCLUDE
    let $LIB     = s:ICC_Install_DIR . 'lib\ia32;'. $LIB
endfunction

function! <SID>:Set_JAVA_Working_Env_Variable()
endfunction

" Description:
"    the script heavily depends on the Visual C++'s tools, this
"    function set the appropriate environment variable PATH, INCLUDE, LIB to
"    make cl.exe works well
"    Calling it more than once is OK
"    Most of the environment variable must be same as vcvars32.bat
function! <SID>:Set_VC_Working_Env_Variable(vc_inst_dir)
  let add_path =[a:vc_inst_dir . 'Common7\IDE;' ,
    \ a:vc_inst_dir . 'VC\BIN;' ,
    \ a:vc_inst_dir . 'Common7\Tools;' ,
    \ a:vc_inst_dir . 'VC\VCPackages;' ]
  " Reset PATH to the origin PATH environment variable
  let $PATH = s:origin_PATH
  for p in add_path
    " ChangeLog: Always prepend to $PATH
    "if ( $PATH !~? escape(p, '\') )
      let $PATH= p . $PATH
    "endif
  endfor

  let add_path = [a:vc_inst_dir . 'VC\ATLMFC\INCLUDE;' ,
    \ a:vc_inst_dir . 'VC\INCLUDE;' ,
    \ s:Win_SDK_DIR    . 'include;' ,
    \ s:Boost_root . ';' ]
  let $INCLUDE = s:origin_INCLUDE
  for p in add_path
    " ChangeLog: Always prepend to $INCLUDE
    " if ( $INCLUDE !~? '\%(^\|;\)' . escape(p, '\') )
      let $INCLUDE = p . $INCLUDE
    "endif
  endfor

  let add_path = [
    \ a:vc_inst_dir . 'VC\ATLMFC\LIB;' ,
    \ a:vc_inst_dir . 'VC\LIB;' ,
    \ s:Win_SDK_DIR    . 'LIB;' ,
    \ s:Boost_root     . 'LIB;' ]
  let $LIB = s:origin_LIB
  for p in add_path
    " ChangeLog: Always prepend to $LIB
    " if ( $LIB !~? '\%(^\|;\)' . escape(p, '\')  )
      let $LIB = p . $LIB
    "endif
  endfor

  " for managed C++/CLI #using statement
  let add_path = [
    \ a:vc_inst_dir . 'VC\ATLMFC\LIB;' ,
    \ a:vc_inst_dir . 'VC\LIB;' ]
  let $LIBPATH = s:origin_LIBPATH
  for p in add_path
    " ChangeLog: Always prepend to $LIBPATH
    " if ( $LIBPATH !~? '\%(^\|;\)' . escape(p, '\')  )
      let $LIBPATH = p . $LIBPATH
    " endif
  endfor

endfunction

" Description:
"    the script heavily depends on the Visual C++'s tools, this
"    function set the appropriate environment variable PATH, INCLUDE, LIB to
"    make cl.exe works well
"    Calling it more than once is OK
"    Most of the environment variable must be same as vcvars32.bat
function! <SID>:Set_VC_x64_Working_Env_Variable(vc_inst_dir)
  let add_path =[a:vc_inst_dir . 'VC\BIN\amd64;' ,
    \ a:vc_inst_dir . 'Common7\IDE;' ,
    \ a:vc_inst_dir . 'Common7\Tools;' ,
    \ a:vc_inst_dir . 'VC\VCPackages;' ]
  " Reset PATH to the origin PATH environment variable
  let $PATH = s:origin_PATH
  for p in add_path
    " ChangeLog: Always prepend to $PATH
    "if ( $PATH !~? escape(p, '\') )
      let $PATH= p . $PATH
    "endif
  endfor

  let add_path = [a:vc_inst_dir . 'VC\ATLMFC\INCLUDE;' ,
    \ a:vc_inst_dir . 'VC\INCLUDE;' ,
    \ s:Win_SDK_DIR    . 'include;' ,
    \ s:Boost_root . ';' ]
  let $INCLUDE = s:origin_INCLUDE
  for p in add_path
    " ChangeLog: Always prepend to $INCLUDE
    " if ( $INCLUDE !~? '\%(^\|;\)' . escape(p, '\') )
      let $INCLUDE = p . $INCLUDE
    "endif
  endfor

  let add_path = [
    \ a:vc_inst_dir . 'VC\ATLMFC\LIB\amd64;' ,
    \ a:vc_inst_dir . 'VC\LIB\amd64;' ,
    \ s:Win_SDK_DIR    . 'LIB\x64;' ,
    \ s:Boost_root     . 'LIB;' ]
  let $LIB = s:origin_LIB
  for p in add_path
    " ChangeLog: Always prepend to $LIB
    " if ( $LIB !~? '\%(^\|;\)' . escape(p, '\')  )
      let $LIB = p . $LIB
    "endif
  endfor

  " for managed C++/CLI #using statement
  let add_path = [
    \ a:vc_inst_dir . 'VC\ATLMFC\LIB\amd64;' ,
    \ a:vc_inst_dir . 'VC\LIB\amd64;' ]
  let $LIBPATH = s:origin_LIBPATH
  for p in add_path
    " ChangeLog: Always prepend to $LIBPATH
    " if ( $LIBPATH !~? '\%(^\|;\)' . escape(p, '\')  )
      let $LIBPATH = p . $LIBPATH
    " endif
  endfor

endfunction

" Description:
"   Compile the PCH file
" Depends on dir:
"     D:\work\C_CPP
" Depends on files:
"        pch_compile_out.txt  (readable-writable)
"        my_precompile_header.cpp (readable)
function! <SID>:Compile_PCH(vc_platform)
  if a:vc_platform == ''
    call <SID>:Set_VC_Working_Env_Variable(s:VS_Install_DIR)
    let cc_full_path = s:cl_full_path
  elseif a:vc_platform == 'x64'
    call <SID>:Set_VC_x64_Working_Env_Variable(s:VS_Install_DIR)
    let cc_full_path = s:cl_x64_full_path
  endif

  exe 'silent! !del ' . s:pch_fname

  if v:shell_error
    echohl "Fail to delete / overwrite [" . s:pch_fname . "] file, use unlocker to delete it"
    return
  endif

  " ChangeLog: forget to save the .h file before compiling
  silent update
  exe 'silent! !"' . cc_full_path . '" /W4 /MD /WX /Zi /wd4793 /Yc /c /EHa ' . s:pch_cpp_fname .
        \ ' 2>&1 >'. s:pch_compile_out
  let is_compile_ok = v:shell_error
  let has_2_win = tabpagewinnr( tabpagenr(), '$' ) > 1
  " If Compile OK, there's no meaningful info, so just return
  if ! v:shell_error
    echo "Create precompiled file FrequentlyUsedHeaders.PCH OK"
    " Close the error window if there is before return
    if has_2_win
      exe "norm \<C-W>b"
      q!
    endif
    return
  endif

  " There's Error: Open a new window to read the pch_compile_out.txt file
  if has_2_win
    " Go to the bottom window
    exe "norm \<C-W>b"
  else
    setlocal splitbelow
    new
  endif
  " Delete the existing contents at first
  1,$d
  exe '0r ' . s:pch_compile_out
endfunction

function! <SID>:DeleteFile(fname)

  if !filereadable(a:fname)
    silent echo "File [". a:fname . "] deleted OK"
    return
  endif

  "exe 'silent! !start ' . s:my_vim_shell . ' N del /F /Q ' . a:fname
  " use delete({filename}) to delete a file instead of the following
  " complex command
  " exe printf('silent! !start %s %s N cmd /c "del /F /Q %s" ', s:my_vim_shell, s:working_DIR, a:fname)
  let i = 0
  " 1 min time out
  silent echo "Try 10 times(100ms as interval) to delete file ..."
  while ( filereadable(a:fname)  && i < 10 )
    call delete(a:fname)
    if( !filereadable(a:fname) )
      break
    endif
    sleep 100m
    let i = i+1
  endwhile

  if filereadable(a:fname)
    echo "Fail to delete file [" . a:fname . "], use unlocker"
  endif
  silent echo "File [". a:fname . "] deleted OK"

endfunction

" Description:
"            Save the current buffer's content to file CPP_Snippet.cpp
function! <SID>:Save_to_Snippet_file(fname)
  norm gg"ayG
  let lines = split(@a, "\n")
  let i = 0
  let n_lines = len(lines)
  while i < n_lines
    " convert the current encoding to OEM-ed code page
    let lines[i] = iconv(lines[i], &encoding, 'cp936')
    let i = i+1
  endwhile
  call writefile(lines, a:fname)
endfunction

function! <SID>:Create_keymap_for_cpp()
  exe 'noremap <buffer> <silent> <F5> :cd '   . s:working_DIR . ' <Bar> call <SID>:Compile_AND_Run("msvc")<CR>'
  exe 'noremap <buffer> <silent> <S-F5> :cd ' . s:working_DIR . ' <Bar> call <SID>:Compile_AND_Run("msvc_x64")<CR>'
  exe 'noremap <buffer> <silent> <F6> :cd '   . s:working_DIR . ' <Bar> call <SID>:Compile_AND_Run("gcc")<CR>'
  exe 'noremap <buffer> <silent> <F7> :cd '   . s:working_DIR . ' <Bar> call <SID>:Compile_AND_Run("icc")<CR>'
  exe 'noremap <buffer> <silent> <F9> :cd '   . s:working_DIR . ' <Bar> call <SID>:PC_Lint_it()<CR>'
  exe 'noremap <buffer> <silent> <F4> :cd '   . s:working_DIR . ' <Bar> call <SID>:Toggle_W0_W4()<CR>'
  exe 'noremap <buffer> <silent> <C-K><C-I> :cd ' . s:working_DIR .
     \  ' <Bar> call <SID>:Edit_Precompiled_Header()<CR>'
endfunction

function! <SID>:Create_keymap_for_java()
  exe 'noremap <buffer> <silent> <F5> :cd '   . s:working_DIR . ' <Bar> call <SID>:Compile_AND_Run("java")<CR>'
endfunction

function! <SID>:Create_keymap_for_asm32()
 exe 'noremap <buffer> <silent> <C-F7> :cd '   . s:working_DIR . ' <Bar> call <SID>:CompileOnly("asm32")<CR>'
endfunction

function! <SID>:Create_keymap_for_asm64()
 exe 'noremap <buffer> <silent> <C-F7> :cd '   . s:working_DIR . ' <Bar> call <SID>:CompileOnly("asm64")<CR>'
endfunction

" Description:
"    If there exist more than one window on the current tab,
"    switch to the bottom one.
"    If not exist, split a new buffer under the current one,
"    and switch to it.
" snippet_id: an id represents the target snippet: c++, java, asm32, asm64, lint
"    , which determines the key map in the output window(when create
"    new)
function! <SID>:Make_sure_switch_to_bottom_window(snippet_id)
  if tabpagewinnr( tabpagenr(), '$' ) > 1
    " Go to the bottom window
    exe "norm \<C-W>b"
  else
    setlocal splitbelow
    new
    if a:snippet_id == 'c++'
        call <SID>:Create_keymap_for_cpp()
    elseif a:snippet_id == 'java'
        call <SID>:Create_keymap_for_java()
    elseif a:snippet_id == 'asm32'
        call <SID>:Create_keymap_for_asm32()
    elseif a:snippet_id == 'asm64'
        call <SID>:Create_keymap_for_asm64()
    elseif a:snippet_id == 'lint'
        " do nothing
    else
        echoerr "Unknown snippet id: [" . a:snippet_id . "], expected: c++,java,asm32,asm64,lint"
    endif
  endif
endfunction

function! <SID>:Append_lines_from(file, start_line)
  let all_lines = readfile(a:file)
  let lines_to_append = []
  if $VIM_CPP_SNIPPET_COMPILER_ENCODING == '1' && len(all_lines) > 0 && a:start_line == 0 
    let all_lines[0] = substitute(all_lines[0], "^\xef\xbb\xbf", '', '')
  endif
  exe 'let lines_to_append = all_lines[' . a:start_line . ': -1]'
  if len(lines_to_append) > 0
    echo len(lines_to_append) . " lines to append"
    " Go to the last line and append the lines
    norm GYp
    :s#.*#\=join(lines_to_append, "\n")#
    redraw
  endif
  return len(all_lines)
endfunction

" Description:
"             Read lines periodically from output_file and append to the
"             end of the current buffer
" @param end_file    : if end_file exist, return, otherwise, always loop
" @param output_file : The text files to append to the current buffer
function! <SID>:Append_lines(end_file, output_file)
  let line_no = 0
  while ! filereadable(a:end_file) 
    " Read the lines of the output
    if filereadable(a:output_file)
      let line_no = <SID>:Append_lines_from(a:output_file, line_no)
    endif

    " wait a minute
    sleep 100m
  endwhile

  if filereadable(a:output_file)
    call <SID>:Append_lines_from(a:output_file, line_no)
  endif
  echo "last line number: " . line_no
endfunction

" Get the // CC_OPTIONS: extra compiler options for gcc if exists
" or Get the // CL_OPTIONS: extra compiler options for vc if exists
" The side effects: the :g command will change the current cursor position
function! <SID>:Get_CC_OPTIONS(cc)
  let old_t = @t
  let @t=''
  exe 'silent g#^\s*/[/*]\s*' . a:cc . '\s*:#y T'
  " Remove the leading // CC_OPTIONS:  or /* CC_OPTIONS 
  let pure_cc_options = substitute(@t, '^\n\|\%(^\|\n\@<=\)\s*/[/*]\s*' . a:cc. '\s*:\s*', '', 'g')
  " Remove the interleaving \n characters
  let pure_cc_options = substitute(pure_cc_options, '\s*\%(\*/\)\?\s*\n', ' ', 'g')
  " Restore the register t
  let @t = old_t
  return pure_cc_options
endfunction

" Get the // LD_OPTIONS: extra compiler options if exists
" The side effects: the :g command will change the current cursor position
function! <SID>:Get_LD_OPTIONS()
	let old_t = @t
	let @t=''
	silent g#^\s*/[/*]\s*LD_OPTIONS\s*:#y T
	" Remove the leading // LD_OPTIONS:  or /* LD_OPTIONS 
	let pure_ld_options = substitute(@t, '^\n\|\%(^\|\n\@<=\)\s*/[/*]\s*LD_OPTIONS\s*:\s*', '', 'g')
	" Remove the interleaving \n characters
	let pure_ld_options = substitute(pure_ld_options, '\s*\%(\*/\)\?\s*\n', ' ', 'g')
	" Restore the register t
	let @t = old_t
	return pure_ld_options
endfunction

" Compile the D:\work\C_CPP\CPP_Snippet.cpp  program
" AND
" Run it if compiled OK
" Anyway, switch to or open an error window in the current tabpage on the bottom,
"     and show the compile error message(if any) or run result(otherwise) in it.
" The redirection file is D:\work\C_CPP\compile_out.txt
" Depends on dir D:\work\C_CPP
" Depends on files:
"       CPP_Snippet.cpp  (writable)
"       CPP_Snippet.exe  (writable)
"       compile_out.txt  (writable)
function! <SID>:Compile_AND_Run(cc)
  " make sure in the top window
  exe "norm \<C-W>t"
  let old_view = winsaveview()
  let cc_options = ''
  if a:cc == 'msvc' 
    call <SID>:Set_VC_Working_Env_Variable(s:VS_Install_DIR)
    let cc_options = <SID>:Get_CC_OPTIONS('CL_OPTIONS')
  elseif a:cc == 'msvc_x64' 
    call <SID>:Set_VC_x64_Working_Env_Variable(s:VS_Install_DIR)
    let cc_options = <SID>:Get_CC_OPTIONS('CL_OPTIONS')
  elseif a:cc == 'gcc'
    call <SID>:Set_GCC_Working_Env_Variable()
    let cc_options = <SID>:Get_CC_OPTIONS('CC_OPTIONS')
  elseif a:cc == 'icc'
    call <SID>:Set_ICC_Working_Env_Variable()
    let cc_options = <SID>:Get_CC_OPTIONS('CL_OPTIONS')
  elseif a:cc == 'java'
    call <SID>:Set_JAVA_Working_Env_Variable()
    let cc_options = <SID>:Get_CC_OPTIONS('JAVAC_OPTIONS')
  else
    echo "Do you forget to set environment for compiler [" . a:cc . "]"
  endif
  let ld_options = <SID>:Get_LD_OPTIONS()

  let snippet_fname = (a:cc == 'java') ? s:java_snippet_fname : s:cpp_snippet_fname
  call <SID>:Save_to_Snippet_file(snippet_fname)
  let if_use_pch = search('^#pragma\s\+hdrstop', 'npw') 
  let use_pch = (if_use_pch) ? "/Yu" : ""
  let use_pch_obj = (if_use_pch) ? s:pch_obj_fname : ""

  let v:errmsg = ""
  " exe 'silent! !del ' . s:exe_snippet_fname
  " exe 'silent! !del ' . s:compile_out
  " exe 'silent! !del ' . s:shell_done
  call <SID>:DeleteFile( s:exe_snippet_fname )
  call <SID>:DeleteFile( s:compile_out )
  " Clear the error
  call <SID>:DeleteFile( s:shell_error )
  call <SID>:DeleteFile( s:shell_done )

  call winrestview(old_view)
  let snippet_id = ( (a:cc == 'java') ? 'java' : 'c++')
  call <SID>:Make_sure_switch_to_bottom_window(snippet_id)
  " Delete the existing contents at first, then read the content of the redirect file in
  1,$d
  norm Yp
  redraw

  " disable 4076 warning to avoid 
  " LINK : warning LNK4076: invalid incremental status file 'CPP_Snippet.ilk'; linking nonincrementally
  if (a:cc == "msvc")
    let cc_cmd_line = printf('"%s" /W4 /WX /Zi /wd4793 /MD %s /EHa %s %s %s /link /IGNORE:4076 %s',
          \ s:cl_full_path,
          \ use_pch, cc_options, s:cpp_snippet_fname , use_pch_obj, ld_options)
  elseif (a:cc == 'msvc_x64')
    let cc_cmd_line = printf('"%s" /W4 /WX /Zi /wd4793 /MD %s /EHa %s %s %s /link /IGNORE:4076 %s',
          \ s:cl_x64_full_path,
          \ use_pch, cc_options, s:cpp_snippet_fname , use_pch_obj, ld_options)
  elseif ( a:cc == "icc")
    " Now I don't know about precompiled header support of icc and the
    " compatibility with VC, so just disable it
    let use_pch = ''
    let cc_cmd_line = printf('"%s" /W4     /Zi /MD %s /EHa %s %s                      ',
          \ s:ICC_full_path,
          \ use_pch, cc_options, s:cpp_snippet_fname )
  elseif ( a:cc == "gcc")
    let exe_output = substitute(s:cpp_snippet_fname, '\.cpp$', '.exe', 'i')
    let cc_cmd_line = printf('"%s" -o"%s" -Wno-deprecated -Wall -g %s -I"%s" %s %s', s:exe_gcc, exe_output,
          \ cc_options,
          \ substitute(s:Boost_root, '\\$', '', ''), cc_options, s:cpp_snippet_fname)
  elseif( a:cc == "java")
      let mockito_jar = 'mockito-all-1.9.5.jar'
      let mockito_jar_full_name = substitute(s:java_snippet_fname, '\(^\|[\\/]\)[^\\/]*$', '\1' . mockito_jar, '')
      let extra_jar = ''
      if filereadable(mockito_jar_full_name)
          let extra_jar = printf('-classpath "%s"', mockito_jar_full_name)
      endif
    let cc_cmd_line = printf('javac %s %s %s', extra_jar, cc_options, s:java_snippet_fname)
  endif

  " an environment variable to communication with vimshell.cs
  let $VIM_CPP_SNIPPET_COMPILER_ENCODING = (&encoding == "utf-8")

  let line = "============= Compling: [" . cc_cmd_line . "]...=========="
  1s#.*#\=line
  redraw

  let cmd_line = printf('silent! !start %s /done %s C %s %s',  s:my_vim_shell, s:working_DIR,
        \ s:compile_out , cc_cmd_line)
  exe cmd_line
  let i = 0

  call <SID>:Append_lines(s:shell_done, s:compile_out)

  if a:cc != 'java' && ! filereadable( s:exe_snippet_fname )
    echo "not exist exe file [" . s:exe_snippet_fname . "]"
    return
  endif

  if a:cc == 'java' && ! filereadable( substitute(s:java_snippet_fname, '\.java', '.class', '') )
      echo "not exist class file [" . substitute(s:java_snippet_fname, '\.java', '.class', '')  . ']'
      return
  endif

  if filereadable( s:shell_error )
    return
  endif

  " Continue to execute the generated exe file if compiled OK

  norm GYp
  " Add a blank line
  let msg_lines = ["", "========================== Run the Program  ================="]
  $s#.*#\=msg_lines#
  redraw

  call <SID>:DeleteFile( s:shell_done )
  call <SID>:DeleteFile( s:compile_out )
  " exe 'silent! !start D:\VimShell.exe C ' . s:compile_out . ' ' . s:exe_snippet_fname
  let java_class = substitute(s:java_snippet_fname, '\.java', '', '')
  let exe_prog = (a:cc == 'java') ? printf('java CPP_Snippet%s', '') : s:exe_snippet_fname
  exe printf('silent! !start %s /done %s C %s %s', s:my_vim_shell,
        \ s:working_DIR, s:compile_out, exe_prog)

  call <SID>:Append_lines(s:shell_done, s:compile_out)
  " locate at the last line
  $
endfunction

" Compile the asm file only
" Anyway, switch to or open an error window in the current tabpage on the bottom,
" The redirection file is D:\work\C_CPP\compile_out.txt
" Depends on dir D:\work\C_CPP
" Depends on files:
"       asm32/asm64 snippet file name  (writable)
"       compile_out.txt  (writable)
function! <SID>:CompileOnly(asm_spec)
  " make sure in the top window
  exe "norm \<C-W>t"
  let old_view = winsaveview()
  if a:asm_spec == 'asm32' 
    call <SID>:Set_VC_Working_Env_Variable(s:VS_Install_DIR)
  elseif a:asm_spec == 'asm64' 
    call <SID>:Set_VC_x64_Working_Env_Variable(s:VS_Install_DIR)
  else
    echo "Do you forget to set environment for compiler [" . a:asm_spec . "]"
  endif

  let snippet_fname = (a:asm_spec == 'asm32') ? s:asm32_snippet_fname : s:asm64_snippet_fname
  call <SID>:Save_to_Snippet_file(snippet_fname)

  let v:errmsg = ""
  call <SID>:DeleteFile( s:exe_snippet_fname )
  call <SID>:DeleteFile( s:compile_out )
  " Clear the error
  call <SID>:DeleteFile( s:shell_error )
  call <SID>:DeleteFile( s:shell_done )

  call winrestview(old_view)
  call <SID>:Make_sure_switch_to_bottom_window(a:asm_spec)
  " Delete the existing contents at first, then read the content of the redirect file in
  1,$d
  norm Yp
  redraw

  " disable 4076 warning to avoid 
  " LINK : warning LNK4076: invalid incremental status file 'CPP_Snippet.ilk'; linking nonincrementally
  if (a:asm_spec == "asm32")
    let cc_cmd_line = printf('"%s" /W3 /WX /Zi %s', s:ml_full_path, snippet_fname )
  elseif (a:asm_spec == 'asm64')
    let cc_cmd_line = printf('"%s" /W3 /WX /Zi %s', s:ml64_full_path, snippet_fname )
  endif

  " an environment variable to communication with vimshell.cs
  let $VIM_CPP_SNIPPET_COMPILER_ENCODING = (&encoding == "utf-8")

  let line = "============= Compling: [" . cc_cmd_line . "]...=========="
  1s#.*#\=line
  redraw

  let cmd_line = printf('silent! !start %s /done %s C %s %s',  s:my_vim_shell, s:working_DIR,
        \ s:compile_out , cc_cmd_line)
  exe cmd_line
  let i = 0

  call <SID>:Append_lines(s:shell_done, s:compile_out)

  if filereadable( s:shell_error )
    return
  endif

  $
endfunction

" Description:
"             Run pc-lint on the program and capture the output
function! <SID>:PC_Lint_it()
  if ! filereadable(s:exe_pclint_fname)
    echohl ErrorMsg 
    echoerr "the PC-Lint program [" . s:exe_pclint_fname . '] not exist'
    echohl Normal
    return
  endif

  call <SID>:Set_VC_Working_Env_Variable(s:VS_Install_DIR)
  call <SID>:Save_to_Snippet_file(s:cpp_snippet_fname)

  call <SID>:DeleteFile( s:shell_done )
  call <SID>:DeleteFile( s:compile_out )
  call <SID>:Make_sure_switch_to_bottom_window('lint')
  1,$d
  $s#.*#========================== PC-Lint ....(PC-Lint is slow, please wait)  =================#
  redraw
  exe printf('silent! !start %s /done %s C %s %s %s', s:my_vim_shell,
        \ s:working_DIR, s:compile_out, s:exe_pclint_fname, s:cpp_snippet_fname)

  call <SID>:Append_lines(s:shell_done, s:compile_out)
  " exe '$r ' . s:compile_out
endfunction

" Description:
"             Toggle /W0 and /W4 for the snippet C++ file, if not 0 and
"             not 4, set to /W4 anyway.
"             Assume the following line:
" #pragma warning(push, 0)
function! <SID>:Toggle_W0_W4()
  let old_position = winsaveview()
  let v:errmsg = ""
  silent! 1/^\s*#\s*pragma\s\+warning\s*(\s*push\s*,\s*\d\s*)\s*$/
  if v:errmsg != ""
    echohl ErrorMsg 
    echoerr "expect line [#pragma warning(push, [0-4])] but not found"
    echohl Normal
    return
  endif

  " Clear the error
  let v:errmsg = ""

  " Assume current is /W4
  silent! s#4#0#
  if ( v:errmsg == "" )
    call winrestview(old_position)
    echo "change the warning level to /W0 (Turn off any warning)"
    return
  endif

  " Replace anything to /W4
  s#[0-9]#4#
  echo "change the warning level to /W4 (Turn on all warning)"

  " Restore to the current line
  call winrestview(old_position)
endfunction

" Description:
"    edit the FrequentlyUsedHeaders.h File in a separated tabpage
"    AND, register a buffer-specific <F5> to compile the PCH file
function! <SID>:Edit_Precompiled_Header()
  exe 'tabedit ' . s:pch_header_fname
  map <buffer> <F5> :call <SID>:Compile_PCH('')<CR>
  map <buffer> <S-F5> :call <SID>:Compile_PCH('x64')<CR>
endfunction

function! <SID>:get_template_file_name(id)
    if a:id == 'c++'
        return s:template_cpp
    elseif a:id == 'java'
        return s:template_java
    elseif a:id == 'asm32'
        return s:template_asm32
    elseif a:id == 'asm64'
        return s:template_asm64
    else
        echoerr "not defined template file id: [" . a:id . "]"
        return ''
    endif
endfunction

" Description: switch to snippet working dir(D:\work\C_CPP) and open a
" new file on a new tabpage with the "Default.cpp" as the default
" content
"    register buffer-specific <F5> to compile and optionally run the snippet file
"    register buffer-specific <C-K><C-I> to edit the pre-compiled
"    file(only for C++)
" Depends on dir:
" snippet working dir s:working_DIR(D:\work\C_CPP)
" Depends on files:
"   template_xx.###   (readable)
function! <SID>:Edit_Snippet_Code (template_id)
  tab new
  let b:is_cpp_snippet=1
  let template_file = <SID>:get_template_file_name(a:template_id)
  if a:template_id == 'c++'
      set ft=cpp
  elseif a:template_id == 'java'
      set ft=java
  elseif a:template_id =~ 'asm'
      set ft=masm
  else
      set ft=text
  endif

  exe 'lcd ' . s:working_DIR
  exe '0r ' . template_file
  1/Begin your code/+2

  if a:template_id == 'c++'
    call <SID>:Create_keymap_for_cpp()
  elseif a:template_id == 'java'
    call <SID>:Create_keymap_for_java()
  elseif a:template_id == 'asm32'
    call <SID>:Create_keymap_for_asm32()
  elseif a:template_id == 'asm64'
    call <SID>:Create_keymap_for_asm64()
  endif
endfunction

function! <SID>:Keep_working_dir()
    if b:is_cpp_snippet != 1
        finish
    endif

    exe 'lcd ' . s:working_DIR
endfunction

function! <SID>:Edit_Snippet_Compiler_Plugin()
    exe 'tabe ' . s:current_script_file
endfunction

" Register the public interface
autocmd WinEnter call <SID>:Keep_working_dir()
noremap <C-K><C-P> :call <SID>:Edit_Snippet_Code('c++')<CR>
noremap <C-K><C-M> :call <SID>:Edit_Snippet_Code('asm32')<CR>
noremap <C-K><C-N> :call <SID>:Edit_Snippet_Code('asm64')<CR>
noremap <C-K><C-J> :call <SID>:Edit_Snippet_Code('java')<CR>
command! EditCppSnippetCode call <SID>:Edit_Snippet_Code('c++')
command! EditPrecompiledHeader call <SID>:Edit_Precompiled_Header()
command! EditSnippetCompilerPlugin call <SID>:Edit_Snippet_Compiler_Plugin()
command! -nargs=1 DeleteFile call <SID>:DeleteFile(<f-args>)
