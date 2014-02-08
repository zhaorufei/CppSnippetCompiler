#define TRACE
using System;
using System.ComponentModel;
using System.Configuration;
using System.Drawing;
using System.Collections;
using System.Diagnostics;
using System.Globalization;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Threading;
using System.IO;
using System.Text;
using System.Xml;

// csc /debug+ /t:winexe VimShell.cs

namespace Vim
{
    internal enum RedirectOperation
    {
        Append,
        DoNothing,
        Create,
    }

    public class VimShell
    {
		/// <summary>
		/// <param name="args">
		/// #1: the dir to generate done.txt and  VimShellError.txt
		/// file, the two files contains only one line:
		/// return: *
		/// where * is the process's ExitCode
		///
		/// #2: one of N, A, or C,  if N do nothing, if A append and C
		/// for create new file whose name is the next argument #3
		///
		/// #3: if #2 argument is A or C, is the name of the redirection
		///     file. Otherwise shift all the following arguments left
		///     by 1 position
		///
		/// #4: the command to execute
		/// #5...  the arguments to the command specified in #4
		/// </param>
		/// </summary>
		// if the first argument is /done, will generate this file in
		// the output_dir(in argument) indicating the work is already
		// done, the caller of this process can do something if see the
		// file exist
		const string c_working_done_file = "done.txt";
		const string c_vim_shell_error_fname = "VimShellError.txt";
        private static StreamWriter s_output_FILE = null;

        public static int Main(string[] args)
        {
            // MessageBox.Show("Debug me");
			// Index of N|A|C in the argument list

			ThreadStart show_error_and_exit_1 = delegate()
			{
				Trace.Assert(false, "usage: VimShell.exe [/done] output_dir N|A|C [redir_file] command arg1 arg2...");
				Environment.Exit(1);
			};
            if(args.Length < 1) show_error_and_exit_1();

			bool has_done = args[0] == "/done";

			// Assume the minimum args without redir_file
			int min_n_args = (has_done)? 4 : 3;
            if(args.Length < min_n_args) show_error_and_exit_1();

			int output_dir_idx = (has_done)?1:0;
			string output_dir = args[ output_dir_idx ];

			int op_idx = (has_done? 2 : 1);

            RedirectOperation op = new RedirectOperation();
            switch (args[op_idx])
            {
                case "A":
                    op = RedirectOperation.Append;
                    break;   
                case "C":
                    op = RedirectOperation.Create;
                    break;   
                case "N":
                    op = RedirectOperation.DoNothing;
                    break;   
                default:
                    Trace.Assert(false, "Wrong parameter: " + args[op_idx] );
                    return 1;
            }
			// There's additional redirection file for standard output
			// and standard error
			if( op != RedirectOperation.DoNothing ) min_n_args += 1;

			// Assert the command format
            if(args.Length < min_n_args) show_error_and_exit_1();

            int command_idx = (op == RedirectOperation.DoNothing) ? op_idx + 1 : op_idx + 2;

            string redir_file = (op == RedirectOperation.DoNothing) ? null : args[op_idx+1];
            try
            {
                ProcessStartInfo psi = new ProcessStartInfo( args[command_idx]);
                StringBuilder sb = new StringBuilder();
                if (op == RedirectOperation.DoNothing)
                {
                    sb.AppendFormat(@"{0}", string.Join(" ", args, command_idx + 1, args.Length - command_idx - 1));
                    if (redir_file != null)
                    {
                        s_output_FILE = new StreamWriter(redir_file, false);
                    }
                }
                else
                {
                    sb.AppendFormat(@"{0}", string.Join(" ", args, command_idx + 1, args.Length - command_idx - 1));
                    if (redir_file != null)
                    {
						bool output_utf8_encoding = Environment.GetEnvironmentVariable(
								"VIM_CPP_SNIPPET_COMPILER_ENCODING") == "1";
                        s_output_FILE = new StreamWriter(redir_file, true, 
								(output_utf8_encoding)?Encoding.UTF8 : Encoding.Default );
                    }
                }

                psi.Arguments = sb.ToString();
                psi.UseShellExecute = false;
                psi.CreateNoWindow = true;
                psi.RedirectStandardOutput = true;
                psi.RedirectStandardError = true;

                Process p = new Process();
				p.StartInfo = psi;

                p.OutputDataReceived += p_OutputDataReceived;
                p.ErrorDataReceived += p_OutputDataReceived;
                p.Start();
                p.BeginOutputReadLine();
                p.BeginErrorReadLine();
                p.WaitForExit();

                if (s_output_FILE != null)
                {
                    s_output_FILE.Close();
                }

                int exit_code = p.ExitCode;
                if (has_done)
                {
					string working_done = Path.Combine(output_dir, c_working_done_file );
                    using (StreamWriter f = new StreamWriter(working_done))
                    {
                        f.WriteLine("return: " + exit_code);
                    }
                }
                if( p.ExitCode != 0)
                {
					string error_fname  = Path.Combine(output_dir, c_vim_shell_error_fname );
                    using (StreamWriter f = new StreamWriter(error_fname))
                    {
                        f.WriteLine("return: " + exit_code);
                    }
					return p.ExitCode;
                }
            }
            catch (Exception ex)
            {
                Trace.Assert(false, ex.ToString());
            }
            return 0;
        }

        private static VimShell s_lock_obj = new VimShell();
        static void p_OutputDataReceived(object sender, DataReceivedEventArgs e)
        {
            if (s_output_FILE != null && !String.IsNullOrEmpty(e.Data))
            {
                lock (s_lock_obj)
                {
                    s_output_FILE.WriteLine(e.Data);
                    s_output_FILE.Flush();
                }
            }
        }
    }
}
