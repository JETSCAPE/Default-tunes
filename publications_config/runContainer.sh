#!/bin/bash

###############################################################################
# Copyright (c) The JETSCAPE Collaboration, 2018
#
# For the list of contributors see AUTHORS.
#
# Report issues at https://github.com/JETSCAPE/JETSCAPE/issues
#
# or via email to bugs.jetscape@gmail.com
#
# Distributed under the GNU General Public License 3.0 (GPLv3 or later).
# See COPYING for details.
##############################################################################

# This script runs a Docker or Apptainer container for a specified
# version of JETSCAPE or X-SCAPE. Docker or Apptainer must be installed on
# the host system and accessible from the Linux bash shell.
#
# This script takes two command line arguments:
# 1) The path to the user input XML file.
# 2) The image repository and tag for the JETSCAPE or X-SCAPE version.
#    For example: jetscape_full:v3.7.1
#
# The JETSCAPE and X-SCAPE images are available at:
# https://hub.docker.com/r/jetscape/jetscape_full
# https://hub.docker.com/r/jetscape/xscape_full
#
# Example usage:
# ./runContainer.sh arXiv_1910.05481/jetscape_user_PP_1910.05481.xml jetscape_full:v3.7.1
#
# The script then copies output .dat files to the host current directory.

# check command line arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_xml> <image_repository:tag>"
    echo "Example: $0 arXiv_1910.05481/jetscape_user_PP_1910.05481.xml jetscape_full:v3.7.1"
    exit 1
fi

input_xml=$1
image_repo_tag=$2

# set accordingly for JETSCAPE or X-SCAPE
if [[ "$image_repo_tag" == jetscape_full* ]]; then
    repo_name="JETSCAPE"
elif [[ "$image_repo_tag" == xscape_full* ]]; then
    repo_name="X-SCAPE"
else
    echo "Error: image repository name must be jetscape_full or xscape_full"
    exit 1
fi

# check if input XML file exists
if [ ! -f "$input_xml" ]; then
    echo "Error: Input XML file '$input_xml' not found"
    exit 1
fi

repo_base="/home/jetscape-user/$repo_name"
build_dir="$repo_base/build"
entry_point="$build_dir/runJetscape"
host_mount_dir="$repo_base/host"

# unique temporary directory on the host
host_tmp_dir=$(mktemp -d -p "$(pwd)" build_tmp_XXXXXX)
host_tmp_dir_file=$(basename "$host_tmp_dir")
build_host="$repo_base/$host_tmp_dir_file"

# script to run inside the container
container_script=$(cat <<EOF
cp -r "$build_dir"/* "$build_host" && \
cd "$build_host" && \
"$entry_point" "$host_mount_dir/$input_xml" && \
cp *.dat "$host_mount_dir"
EOF
)

# run the Docker container if Docker is available
if command -v docker &> /dev/null; then
    echo "Running Docker command..."
    docker run --rm \
      -w "$repo_base" \
      -u "$(id -u):$(id -g)" \
      -v "$(pwd):$host_mount_dir" \
      -v "$host_tmp_dir:$build_host" \
      --entrypoint /bin/bash \
      "jetscape/$image_repo_tag" \
      -c "$container_script"

# run the Apptainer container if Apptainer is available
elif command -v apptainer &> /dev/null; then
    echo "Running Apptainer command..."
    apptainer exec \
      --pwd "$repo_base" \
      --bind "$(pwd):$host_mount_dir,$host_tmp_dir:$build_host" \
      docker://jetscape/$image_repo_tag \
      bash -c "$container_script"

# run the Singularity container if Singularity is available
elif command -v singularity &> /dev/null; then
    echo "Running Singularity command..."
    singularity exec \
      --pwd "$repo_base" \
      --bind "$(pwd):$host_mount_dir,$host_tmp_dir:$build_host" \
      docker://jetscape/$image_repo_tag \
      bash -c "$container_script"

# error if none are available
else
    echo "Error: neither Docker nor Apptainer is available"
    exit 1
fi

# .dat files are copied to the host current directory
# if other generated files are wanted, comment out the rm command
rm -rf "$host_tmp_dir"
