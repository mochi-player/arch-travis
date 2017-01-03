#!/bin/bash
# Copyright (C) 2016  Mikkel Oscar Lyderik Larsen
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Script for setting up and running a travis-ci build in an up to date


# read value from .travis.yml
travis_yml() {
  ruby -ryaml -e 'puts ARGV[1..-1].inject(YAML.load(File.read(ARGV[0]))) {|acc, key| acc[key] }' .travis.yml $@
}

run() {
  "$@"
  local ret=$?

  if [ $ret -gt 0 ]; then
    exit $ret
  fi
}

as_normal() {
  local cmd="$@"
  run /bin/bash -c "$cmd"
}

read_config() {
    local old_ifs=$IFS
    IFS=$'\n'
    CONFIG_BUILD_SCRIPTS=($(travis_yml brew script))
    CONFIG_PACKAGES=($(travis_yml brew packages))
    IFS=$old_ifs
}

# run build scripts defined in .travis.yml
build_scripts() {
  if [ ${#CONFIG_BUILD_SCRIPTS[@]} -gt 0 ]; then
    for script in "${CONFIG_BUILD_SCRIPTS[@]}"; do
      as_normal $script
    done
  else
    echo "No build scripts defined"
    exit 1
  fi
}

# install packages defined in .travis.yml
install_packages() {
  as_normal "brew update"
  as_normal "brew install ${CONFIG_PACKAGES[@]}"
}

read_config
install_packages
build_scripts
