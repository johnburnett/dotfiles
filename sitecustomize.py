# coding=utf-8
print('Running "%s"' % __file__)

def main():
    import site
    import sys

    # Hacky, but "import bpy" doesn't work while sitecustomize is running on
    # startup, and not sure how else to discover we're in a Blender hosted
    # Python interpreter.
    in_blender = 'blender' in sys.executable.lower()

    try:
        import rich.console
        import rich.traceback
    except ImportError:
        pass
    except:
        raise
    else:
        console = None
        if in_blender:
            # Would prefer color tracebacks, but the Python Console in Blender
            # itself is monochrome.  The "stderr=True" comes from how rich
            # itself constructs the default Console when it is unsupplied in the
            # traceback.install call.
            console = rich.console.Console(stderr=True, color_system=None)

        rich.traceback.install(
            console=console,
            show_locals=True,
            locals_hide_dunder=False,
            indent_guides=False,
        )
        print('Installed rich traceback handler')


main()
del main
del __file__
