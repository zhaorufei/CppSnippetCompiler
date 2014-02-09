
" Get the output of ":scriptnames" in the scriptnames_output variable.
let g:scriptnames_output = ''
redir => g:scriptnames_output
silent scriptnames
redir END
let s:script_names = split(g:scriptnames_output, "\n")
let s:last_script = s:script_names[-1]
let s:last_script = substitute(s:last_script, '^[^/]*', '', '')
let s:current_script_dir = substitute(s:last_script, '[^/]*$', '', '')
exe ":pyf " . s:current_script_dir . "cmd_runner.py"
