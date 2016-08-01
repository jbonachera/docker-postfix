#!/usr/bin/env python

import os
import sys
from jinja2 import Environment, FileSystemLoader


def main(tpl_file, env):
    """
    Output tpl_file on stdout after template rendering
    """
    current_dir = os.path.dirname(os.path.abspath(tpl_file))
    j2_env = Environment(loader=FileSystemLoader(current_dir),
                         trim_blocks=True)
    print(j2_env.get_template(os.path.basename(tpl_file)).render(env))

main(sys.argv[1], os.environ)
