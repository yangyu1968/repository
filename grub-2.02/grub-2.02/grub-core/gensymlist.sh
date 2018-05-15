#! /bin/sh
#
# Copyright (C) 2002,2006,2007,2008,2009,2010  Free Software Foundation, Inc.
#
# This gensymlist.sh.in is free software; the author
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.

cat <<EOF
/* This file is automatically generated by gensymlist.sh. DO NOT EDIT! */
/*
 *  GRUB  --  GRand Unified Bootloader
 *  Copyright (C) 2002,2006,2007,2008,2009,2010  Free Software Foundation, Inc.
 *
 *  GRUB is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  GRUB is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with GRUB.  If not, see <http://www.gnu.org/licenses/>.
 */

EOF

for i in $*; do
  echo "#include <$i>"
done

cat <<EOF

#define COMPILE_TIME_ASSERT(cond) switch (0) { case 1: case !(cond): ; }

#pragma GCC diagnostic ignored "-Wmissing-format-attribute"

void
grub_register_exported_symbols (void)
{
EOF

cat <<EOF
  struct symtab { const char *name; void *addr; int isfunc; };
  struct symtab *p;
  static struct symtab tab[] =
    {
EOF

(while read LINE; do echo $LINE; done) \
  | grep -v '^#' \
  | sed -n \
        -e '/EXPORT_FUNC *([a-zA-Z0-9_]*)/{s/.*EXPORT_FUNC *(\([a-zA-Z0-9_]*\)).*/      {"\1", \1, 1},/;p;}' \
        -e '/EXPORT_VAR *([a-zA-Z0-9_]*)/{s/.*EXPORT_VAR *(\([a-zA-Z0-9_]*\)).*/      {"\1", (void *) \&\1, 0},/;p;}' \
  | sort -u

cat <<EOF
      {0, 0, 0}
    };

  COMPILE_TIME_ASSERT (sizeof (tab) > sizeof (tab[0]));
  for (p = tab; p->name; p++)
    grub_dl_register_symbol (p->name, p->addr, p->isfunc, 0);
}
EOF
