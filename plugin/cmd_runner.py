import os
import time
import thread
import string
import subprocess
import sys
import signal

import vim

win_before_output = 0
output_buf = None
init_tabpage = -1
cmd_aborted = 0
def switch_to_output_window():
    """ Switch to the output window, safe_output use vim command "$" to put cursor
    at the end of the buffer.
    Side effect: 
    1. to set global variable output_buf if it's value is None.
    2. set global variable win_before_output to the current window number
    
"""
    global win_before_output
    global output_buf
    # Store current window
    win_before_output = vim.eval("winnr()")
    # Switch to the last window
    vim.command( vim.eval("winnr('$')") + "wincmd w" )
    if output_buf == None:
        output_buf = vim.current.buffer

def switch_to_prev_window():
    """ Switch to window whose number is win_before_output
"""
    global win_before_output
    # Restore the origin window
    vim.command( win_before_output + "wincmd w")

def safe_output(lines):
    """ Append lines to global variable output_buf, if the tabpage in which target
    buffer resides is same as the current tabpage, then the target buffer will
    be scrolled automatically to make the latest output visible.
    After the output, the cursor will be switched to origin window before calling
    this function.
"""
    global cmd_aborted
    for one_line in lines:
        output_buf.append(one_line)
        if cmd_aborted == 1:
            break
    curr_tabpage = int( vim.eval("tabpagenr()") )
    if curr_tabpage == init_tabpage:
        switch_to_output_window()
        vim.command("$ | redraw")
        switch_to_prev_window()

def kill_aborted_process(proc, prog_name):
    try:
        if sys.version_info >= (2, 6):
            proc.terminate()
            #time.sleep(0.1)
            # avoid defunct process(at least in linux)
            proc.wait()
        else:
            if os.sep == '/':
                os.kill(proc.pid, signal.SIGKILL)
            else:  # windows
                os.system("taskkill /im %s" % prog_name)
    except:
        global ex_msg
        ex_msg = sys.exc_info()

def redraw_output_tabpage():
    curr_tabpage = int ( vim.eval("tabpagenr()") )
    global init_tabpage
    if init_tabpage != curr_tabpage:
        vim.command("tabnext %d" % init_tabpage)
        switch_to_output_window()
        vim.command("$ | redraw")
        switch_to_prev_window()
        vim.command("tabnext %d" % curr_tabpage)

# run list of cmd + args in @all_cmd_and_args, the next cmd will be run only
# when the previous cmd exit successfully.
# all_cmd_and_args, 2-level nested list, each item is a list, which is a command
# and the optional arguments
def run_piped_cmd_and_redirect_output_no_exception(all_cmd_and_args):
    global cmd_aborted
    if len(all_cmd_and_args) == 1:
        all_cmd_and_args = all_cmd_and_args[0]
    for one_cmd_and_args in all_cmd_and_args:
        print one_cmd_and_args
        proc = subprocess.Popen(one_cmd_and_args, shell=False, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        proc_info = "Running process(PID=%d): [%s]" % (proc.pid, string.join(one_cmd_and_args, ' ') )
        safe_output( (proc_info,) )
        # continue
        while True:
            if cmd_aborted == 1:
                break
            line = proc.stdout.readline()
            if not line:
                one_char = proc.stdout.read(1)
                if not one_char:  # I think it's eof
                    break
            safe_output((line,))

        if cmd_aborted == 1:
            kill_aborted_process(proc, one_cmd_and_args[0])

        if cmd_aborted != 1:
            proc.poll()
            proc_ret_code = proc.returncode
            safe_output(("==== Finished ====",))
        else:
            safe_output(("==== Aborted ====",))

        redraw_output_tabpage()

        # If previous cmd failed or aborted, then stop to run next
        if cmd_aborted == 1 or proc_ret_code != 0:
            break

def run_piped_cmd_and_redirect_output(all_cmd_and_args):
    run_piped_cmd_and_redirect_output_no_exception((all_cmd_and_args,))

def run_piped_cmd_and_wait_all_output(all_cmd_and_args):
    """ A simple, alternate way to start a new command and read back all its output via 
    pipe, but in batch mode, return only when all the output is read
    """
    for one_cmd_and_args in all_cmd_and_args:
        proc = subprocess.Popen(one_cmd_and_args, shell=False, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        safe_output(proc.stdout.readlines())
        proc.poll()
        if proc.returncode != 0:
            break

# This variable is used to debug the script itself
ex_msg = None
def cmd_runner(cmd_and_args):
    """ Run command with it's companion arguments one by one, in a new thread.
    @cmd_and_args: ( (cmd1, cmd1_arg1, cmd1_arg2, ...),  (cmd2, cmd2_arg1, cmd2_arg2, ...) )
"""
    # the side effect is to save the current buffer for output
    global win_before_output
    global output_buf
    global cmd_aborted
    global init_tabpage
    global ex_msg
    ex_msg = None
    win_before_output = 0
    output_buf = None
    # Return value of vim.eval is always string
    init_tabpage = int( vim.eval("tabpagenr()") )
    switch_to_output_window()
    switch_to_prev_window()
    cmd_aborted = 0
    thread.start_new(run_piped_cmd_and_redirect_output, (cmd_and_args,))
    #thread.start_new(run_piped_cmd_and_wait_all_output, (cmd_and_args,))
