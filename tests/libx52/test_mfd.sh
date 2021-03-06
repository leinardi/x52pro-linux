#!/bin/bash
# MFD tests
#
# Copyright (C) 2012-2018 Nirenjan Krishnan (nirenjan@nirenjan.org)
#
# SPDX-License-Identifier: GPL-2.0-only WITH Classpath-exception-2.0

source $(dirname $0)/../common_infra.sh

TEST_SUITE_ID="libx52 MFD text tests"

# Take in input as a string, and convert them to list of MFD set format
format_text()
{
    local clear_index=`eval echo $1`
    local set_index=`eval echo $2`
    local input_string=$3
    local output_list="$clear_index 0"
    local count=0

    while [[ ${#input_string} -gt 1 ]]
    do
        char1=${input_string:0:1}
        char2=${input_string:1:1}
        input_string=${input_string:2}
        output_list="$output_list $set_index $(printf '%02x%02x' \'$char2 \'$char1)"
        ((count+=2))

        # The library ignores strings longer than 16 characters
        if [[ $count -eq 16 ]]
        then
            # Discard the rest of the input string
            input_string=
        fi
    done
    
    if [[ ${#input_string} -eq 1 ]]
    then
        # Add the remaining character, but pad with a space
        output_list="$output_list $set_index $(printf '20%02x' \'$input_string)"
    fi

    echo $output_list
    return 0
}

mfd_text_test()
{
    local line=$1
    local clear_index="\$X52_MFD_LINE_${line}_CLR_INDEX"
    local set_index="\$X52_MFD_LINE_${line}_SET_INDEX"
    local text="$2"
    TEST_ID="Test setting MFD line $line to '$text'"

    set -x
    pattern=$(format_text $clear_index $set_index "$text")
    expect_pattern $pattern
    set +x

    $X52CLI mfd $line "$text"

    verify_output
}

for text in \
    a \
    ab \
    abc \
    abcd \
    abcde \
    abcdef \
    abcdefg \
    abcdefgh \
    abcdefghi \
    abcdefghij \
    abcdefghijk \
    abcdefghijkl \
    abcdefghijklm \
    abcdefghijklmn \
    abcdefghijklmno \
    abcdefghijklmnop \
    abcdefghijklmnopq \
    abcdefghijklmnopqr \
    ;
do
    for line in 0 1 2
    do
        mfd_text_test $line "$text"
    done
done

verify_test_suite

