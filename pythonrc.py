# coding=utf-8
from __future__ import absolute_import as _
from __future__ import division as _
from __future__ import print_function as _
from __future__ import unicode_literals as _

print('Running "%s"' % __file__)

def pythonrc():
    import sys
    if sys.version_info.major > 2:
        return

    import atexit
    import code
    import os
    import platform

    # http://docs.python.org/library/readline.html#module-readline
    # http://docs.python.org/library/rlcompleter.html
    # http://valueerror.wordpress.com/2009/11/03/python-shell-history-autocompletion-and-rc-file/

    if platform.system() != 'Windows':
        def setup_history():
            """Setup history logging on readline style platforms."""
            import readline
            import rlcompleter

            historyFilePath = os.path.expanduser(os.path.join('~', '.python_history'))
            try:
                readline.read_history_file(historyFilePath)
            except:
                pass
            readline.parse_and_bind('tab: complete')
            atexit.register(readline.write_history_file, historyFilePath)

            class HistoryConsole(code.InteractiveConsole):
                def __init__(self, locals=None, filename="<console>", histfile=os.path.expanduser(os.path.join('~', '.python_history'))):
                    code.InteractiveConsole.__init__(self, locals, filename)
                    self.init_history(histfile)

                def init_history(self, histfile):
                    readline.parse_and_bind("tab: complete")
                    if hasattr(readline, "read_history_file"):
                        try:
                            readline.read_history_file(histfile)
                        except IOError:
                            pass
                        atexit.register(self.save_history, histfile)

                def save_history(self, histfile):
                    readline.write_history_file(histfile)


        def wrap_help():
            """On linux, help() goes into an interactive help browser.
            Do not want, as it erases help from terminal when exiting."""
            import pydoc

            def print_help(*args, **kwargs):
                kwargs['title'] = '%s'
                print(pydoc.render_doc(*args, **kwargs))

            global help, help_original
            help_original = help
            help = print_help


        setup_history()
        wrap_help()


pythonrc()
del pythonrc
del __file__
