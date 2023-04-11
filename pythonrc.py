# coding=utf-8
import atexit
import code
import os
import platform
import sys


def noop(*args, **kwargs): pass
info = print
error = print
debug = noop


def setup_history():
    """Setup history logging on readline style platforms.
    """
    # http://docs.python.org/library/readline.html#module-readline
    # http://docs.python.org/library/rlcompleter.html
    # http://valueerror.wordpress.com/2009/11/03/python-shell-history-autocompletion-and-rc-file/
    try:
        import readline
    except ImportError:
        if platform.system().lower() == 'windows':
            error('Error importing readline, install pyreadline3:')
            error(f'{sys.executable} -m pip install pyreadline3')
            return
        raise
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
    Do not want, as it erases help from terminal when exiting.
    """
    if not platform.system().lower() == 'windows':
        import pydoc

        def print_help(*args, **kwargs):
            kwargs['title'] = '%s'
            info(pydoc.render_doc(*args, **kwargs))

        global help, help_original
        help_original = help
        help = print_help


def main():
    if sys.version_info.major < 3:
        return

    setup_history()
    wrap_help()


main()
for name in list(globals().keys()):
    if not name.startswith('_'):
        del globals()[name]
del name
