/* Converted to D from gsl_permute_complex_double.h by htod
 * and edited by daniel truemper <truemped.dsource <with> hence22.org>
 */
module auxc.gsl.gsl_permute_complex_double;
/* permutation/gsl_permute_complex_double.h
 * 
 * Copyright (C) 1996, 1997, 1998, 1999, 2000 Brian Gough
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

import tango.stdc.stdlib;

public import auxc.gsl.gsl_errno;

public import auxc.gsl.gsl_complex;

public import auxc.gsl.gsl_permutation;

extern (C):
int  gsl_permute_complex(size_t *p, double *data, size_t stride, size_t n);

int  gsl_permute_complex_inverse(size_t *p, double *data, size_t stride, size_t n);

