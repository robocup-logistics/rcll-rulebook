#! /usr/bin/env python3
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2020 Till Hofmann <hofmann@kbsg.rwth-aachen.de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# Read the full text in the LICENSE.GPL file in the doc directory.
#
"""
Product/Workpiece picture generator using tikz
"""

import argparse
import itertools
import jinja2
import os
import subprocess

from multiprocessing.pool import ThreadPool


def generate_tex(template, base_color, ring_colors, cap_color):
    print("Generating base: {}, rings: {}, cap: {}".format(
        base_color, ring_colors, cap_color))
    tex = template.render(
        base_color=base_color,
        ring_colors=ring_colors,
        cap_color=cap_color,
    )
    base = [f'BASE_{base_color.upper()}'] if base_color else []
    rings = [f'RING_{ring_color.upper()}' for ring_color in ring_colors] if ring_colors else []
    cap = [f'CAP_{cap_color.upper()}'] if cap_color else []
    items = base + rings + cap
    output_path = f'{"-".join(items)}'

    with open(os.path.join('generated', f'{output_path}.tex'), 'w') as tex_file:
        tex_file.write(tex)

    subprocess.run(['pdflatex', '-output-directory', 'generated', f'{output_path}.tex'],
                    stdout=subprocess.DEVNULL)
    subprocess.run(['pdf2svg', f'{output_path}.pdf', f'{output_path}.svg'], cwd='generated')
   
# note: to only generate valid products, remove 'clear' from the
# `base_colors` list and remove all `thread_pool.apply_async`` calls except the
# one in line 80
def main():
    env = jinja2.Environment(loader=jinja2.FileSystemLoader('templates'))
    template = env.get_template('product.tex.j2')
    base_colors = ['black', 'red', 'silver', 'clear']
    ring_colors = ['green', 'blue', 'orange', 'yellow']
    cap_colors = ['grey', 'black']

    try:
        os.mkdir('generated')
    except OSError:
        pass
    thread_pool = ThreadPool()

    for base in base_colors:
        for complexity in range(0, 4):
            for rings in itertools.product(ring_colors, repeat=complexity):
                # workpiece without cap (single bases and bases with rings)
                thread_pool.apply_async(generate_tex,
                                            (template, base, rings, None))
                for cap in cap_colors:
                    # product
                    thread_pool.apply_async(generate_tex,
                                            (template, base, rings, cap))

    for ring in ring_colors:
        # single ring
        thread_pool.apply_async(generate_tex,
                                    (template, None, [ring], None))

    for cap in cap_colors:
        # single cap
        thread_pool.apply_async(generate_tex,
                                    (template, None, None, cap))

    thread_pool.close()
    thread_pool.join()


if __name__ == '__main__':
    main()