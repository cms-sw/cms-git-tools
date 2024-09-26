#! /bin/bash

# completion function used
#  - for `git-cms-addpkg`, called by `complete`
#  - for `git cms-addpkg`, called by `__git_complete_command` during the
#    completion for the `git` command

# Note: _git_cms_addpkg() exits with a non-zero status to indicate the failure
# to return any completions.
# __git_complete_command ignores the return status of the helper function, and
# will fall back to the default completion showing files and directories.
# This is consistent with the behaviour of the other git subcommands.

function _git_cms_addpkg() {
  # if CMSSW_BASE is not defined, do not return any completions
  if [ -z "${CMSSW_BASE}" ]; then
    COMPREPLY=()
    return 1
  fi

  if [ -d "${CMSSW_BASE}/src/.git" ]; then
    # if the git repository in the local area has already been initialised,
    # list all packages (Dir/SubDir) in the git repository
    local PACKAGES="$(git -C ${CMSSW_BASE}/src ls-files --full-name 2> /dev/null | cut -d/ -s -f1-2 | sort -u)"
  elif [ "${CMSSW_RELEASE_BASE}" ] && [ -d "${CMSSW_RELEASE_BASE}/src" ]; then
    # otherwise, if a release area is defined, list all packages from it
    local PACKAGES="$(cd ${CMSSW_RELEASE_BASE}/src 2> /dev/null; ls -d -1 */*/ | cut -d/ -s -f1-2 | sort -u)"
  fi

  # if listing the packages failed or returned an empty list, do not return any completion
  if [ -z "${PACKAGES}" ]; then
    COMPREPLY=()
    return 1
  fi

  local PREV="${COMP_WORDS[$((COMP_CWORD - 1))]}"
  if [ "$PREV" == "-f" ] || [ "$PREV" == "--file" ]; then
    # -f/--file takes a file as argument, fall back to the default completion
    compopt -o default
    COMPREPLY=()
  else
    # complete the word under the cursor using the list of packages
    COMPREPLY=($(compgen -W "${PACKAGES}" "${COMP_WORDS[$COMP_CWORD]}"))
  fi
}

complete -F _git_cms_addpkg git-cms-addpkg
