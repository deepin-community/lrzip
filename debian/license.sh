#!/bin/sh
#
#   Copyright
#
#       Copyright (C) 2009-2010 Jari Aalto <jari.aalto@cante.net>
#
#   License
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program. If not, see <http://www.gnu.org/licenses/>.
#

PRIMARY_AUTHOR="Kolivas"  # A regexp

TMP=${TEMPDIR:-/tmp}/${LOGNAME:-${USER:-foo}}.tmp
REGEXP='copyright|@|license|author|\(C\).*[0-9]{4}' $file

Help ()
{
    echo "
SYNOPSIS

  PRIMARY_AUTHOR="name" sh debian/license.sh [<root dir to start>]

DESCRIPTION

Examine project CODE files for Copyright and License from current
directory not written by regexp: \$PRIMARY_AUTHOR"

    exit 0
}

Find ()
{
    dir=${1:-.}
    shift

    # Exclude files
    find				\
        -L				\
        $dir				\
        -mount				\
        -type d                         \
            '('                         \
            -name ".bzr"                \
            -o -name ".arch"            \
            -o -name ".git"             \
            -o -name ".hg"              \
            -o -name ".darcs"           \
            -o -name ".svn"             \
            -o -name ".mtn"             \
            -o -name "CVS"              \
            -o -name "RCS"              \
            -o -name "SCCS"             \
            -o -name "_MTN"             \
            -o -name ".inst"            \
            -o -name ".sinst"           \
            -o -name ".build"           \
            -o -name ".quilt"           \
            -o -name ".pc"              \
            -o -name "debian"           \
            ')'                         \
        -prune                          \
        -a ! -name ".arch"              \
        -a ! -name ".bzr"               \
        -a ! -name ".git"               \
        -a ! -name ".hg"                \
        -a ! -name ".darcs"             \
        -a ! -name ".svn"               \
        -a ! -name ".mtn"               \
        -a ! -name "CVS"                \
        -a ! -name "RCS"                \
        -a ! -name "SCCS"               \
        -a ! -name "_MTN"               \
        -a ! -name "*.tmp"              \
        -a ! -name "*[#]*"              \
        -a ! -name "*~"                 \
        -a ! -name "*.orig"             \
        -a ! -name "*.rej"              \
        -a ! -name "*.bak"              \
        -a ! -name ".inst"              \
        -a ! -name ".sinst"             \
        -a ! -name ".build"             \
        -a ! -name ".quilt"             \
        -a ! -name ".pc"                \
        -a ! -name "debian"             \
        -o				\
        "$@"
}

Files ()
{
    LC_ALL=C Find ${1:-.}		\
	-name "*.cc"			\
	-o -name "*.cpp"		\
	-o -name "*.cxx"		\
	-o -name "*.pl"			\
	-o -name "*.py"			\
	-o -name "*.[cC]"		\
	-o -name "*.h"			\
	-o -name "*.hh"			\
	-o -name "*.hxx"		\
	-o -name "*README*"
}

AtExit ()
{
    rm -f $TMP*
}

Main ()
{
    case "$*" in
	-h | --help ) Help ;;
    esac

    files=$TMP.files-all
    Files > $files

    aFiles=$TMP.files-author
    grep -Ei "$PRIMARY_AUTHOR" --files-with-matches $(cat $files) > $aFiles

    for file in $(cat $files)
    do
	if ! grep --with-filename -Ei "$REGEXP" $file; then
	    echo "$file: #WARN: NO INFORMATION (check manually)"
	fi
    done

    echo "---------------- files not by $PRIMARY_AUTHOR"

    grep --with-filename -Ei "$REGEXP" $files $(cat $files | grep -vFf $aFiles)

}

trap 'AtExit' 0 1 2 3 9 15
Main "$@"

# End of file
