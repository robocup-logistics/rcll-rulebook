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
Product picture generator using tikz
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
    tex_path = 'c{complexity}_{base}_{rings}_{cap}.tex'.format(
        complexity=len(ring_colors),
        base=base_color,
        rings='-'.join(ring_colors),
        cap=cap_color)
    with open(os.path.join('generated', tex_path), 'w') as tex_file:
        tex_file.write(tex)
    subprocess.call(['pdflatex', '-output-directory', 'generated', tex_path],
                    stdout=subprocess.DEVNULL)


def main():
    env = jinja2.Environment(loader=jinja2.FileSystemLoader('templates'))
    template = env.get_template('product.tex.j2')
    base_colors = ['black', 'red', 'silver']
    ring_colors = ['green', 'blue', 'orange', 'yellow']
    cap_colors = ['gray', 'black']
    try:
        os.mkdir('generated')
    except OSError:
        pass
    thread_pool = ThreadPool()
    for base in base_colors:
        for complexity in range(0, 4):
            for rings in itertools.permutations(ring_colors, complexity):
                for cap in cap_colors:
                    thread_pool.apply_async(generate_tex,
                                            (template, base, rings, cap))
    thread_pool.close()
    thread_pool.join()


if __name__ == '__main__':
    main()
