# coding=utf-8
import os
import pkgutil
import site
import sys


def noop(*args, **kwargs): pass
info = print
error = print
debug = noop


def install_rich():
    try:
        import rich.console
        import rich.traceback
    except ImportError:
        pass
    except:
        raise
    else:
        console = None
        # Hacky, but "import bpy" doesn't work while sitecustomize is running on
        # startup, and not sure how else to discover we're in a Blender hosted
        # Python interpreter.
        in_blender = 'blender' in sys.executable.lower()
        if in_blender:
            # Would prefer color tracebacks, but the Python Console in Blender
            # itself is monochrome.  The "stderr=True" comes from how rich
            # itself constructs the default Console when it is unsupplied in the
            # traceback.install call.
            console = rich.console.Console(stderr=True, color_system=None)

        rich_modules = []
        import rich
        for importer, modname, ispkg in pkgutil.iter_modules(rich.__path__):
            module = __import__(f'{rich.__name__}.{modname}', fromlist='dummy')
            rich_modules.append(module)

        rich.traceback.install(
            console=console,
            show_locals=True,
            locals_hide_dunder=False,
            indent_guides=False,
            suppress=rich_modules,
        )
        debug('Installed rich traceback handler')


def main():
    install_rich()


main()
for name in list(globals().keys()):
    if not name.startswith('_'):
        del globals()[name]
del name
