#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
  Copyright (c) 2021, ICGC-ARGO-Structural-Variation-CN-WG

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

  Authors:
    alvinwt
"""

import os
import sys
import argparse
import subprocess


def main():
    """
    Python wrapper of svaba

    """

    parser = argparse.ArgumentParser(description='Tool: svaba')
    parser.add_argument('-t', '--input-tumour-bam', dest='input_tumour_bam', type=str,
                        help='Input tumour bam', required=True)
    parser.add_argument('-n', '--input-normal-bam', dest='input_normal_bam', type=str,
                        help='Input normal bam ', required=True)
    parser.add_argument('-D', '--dbsnp-vcf', dest='dbsnp', type=str,
                        help='dbsnp file ', required=True)
    parser.add_argument('-p', '--threads', dest='threads', type=str,
                        help='number of threads', required=True)
    parser.add_argument('-a', '--id-string', dest='id_string', type=str,
                        help='sample id string', required= True)
    parser.add_argument('-R', '--reference-genome', dest='reference', type=str,
                        help='reference genome', required=True)
    args = parser.parse_args()

    if not os.path.isfile(args.input_tumour_bam):
        sys.exit('Error: tumour bam %s does not exist or is not accessible!' % args.input_tumour_bam)

    if not os.path.isfile(args.input_normal_bam):
        sys.exit('Error: normal bam %s does not exist or is not accessible!' % args.input_normal_bam)

    #if not os.path.isdir(args.output_dir):
    #    sys.exit('Error: specified output dir %s does not exist or is not accessible!' % args.output_dir)

    subprocess.run(f"svaba run -t {args.input_tumour_bam} -n {args.input_normal_bam} -p {args.threads} -D {args.dbsnp} -a {args.id_string} -G {args.reference}", shell=True, check=True)


if __name__ == "__main__":
    main()

