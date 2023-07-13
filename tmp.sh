#!/bin/bash
# @file tmp.sh
# @brief Lorem ipsum dolor sit amet, consetetur sadipscing elitr.
#
# @description Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. 
#
# === Script Arguments
#
# The script does not accept any parameters.
# * *$1* (string): Some var
#
# === Script Example
#
# [source, bash]
# ```
# ./tmp.sh
# ```


set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

JQ_QUERY='.[] | "[.menu-item-name]#link:/_personal-projects/" + .name + "/main[" + .name + "]#" + " [.menu-item-desc]#" + .description + "#"'


echo "[INFO] Read personal project from sebastian-sommerfeld-io" 
gh repo list --visibility=public --no-archived --json=name,description --jq="$JQ_QUERY" > docs/modules/ROOT/partials/AUTO-GENERATED/projects/personal.adoc
