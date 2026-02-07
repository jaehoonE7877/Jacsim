#!/usr/bin/env bash
set -euo pipefail

force_all="false"
input_file=""

for arg in "$@"; do
  case "${arg}" in
    --force-all)
      force_all="true"
      ;;
    *)
      input_file="${arg}"
      ;;
  esac
done

changed_files=()
if [[ -n "${input_file}" ]]; then
  if [[ ! -f "${input_file}" ]]; then
    echo "Input file not found: ${input_file}" >&2
    exit 1
  fi
  while IFS= read -r line || [[ -n "${line}" ]]; do
    changed_files+=("${line}")
  done < "${input_file}"
else
  while IFS= read -r line || [[ -n "${line}" ]]; do
    changed_files+=("${line}")
  done
fi

selected_schemes_csv=","
ordered_schemes=("Domain" "ExternalInterface" "Data" "Jacsim")

add_scheme() {
  local candidate="$1"
  if [[ "${selected_schemes_csv}" != *",${candidate},"* ]]; then
    selected_schemes_csv+="${candidate},"
  fi
}

set_full_suite() {
  add_scheme "Domain"
  add_scheme "ExternalInterface"
  add_scheme "Data"
  add_scheme "Jacsim"
}

is_docs_only_file() {
  local file="$1"
  case "${file}" in
    *.md|LICENSE|LICENSE.*|.gitignore|.gitattributes|.editorconfig)
      return 0
      ;;
    design-system/*|memory/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

fallback_full_suite="false"
non_doc_change_detected="false"

if [[ "${force_all}" == "true" ]]; then
  non_doc_change_detected="true"
  set_full_suite
else
  for file in "${changed_files[@]}"; do
    [[ -z "${file}" ]] && continue

    if is_docs_only_file "${file}"; then
      continue
    fi

    non_doc_change_detected="true"

    case "${file}" in
      Projects/Domain/*)
        add_scheme "Domain"
        add_scheme "ExternalInterface"
        add_scheme "Data"
        add_scheme "Jacsim"
        ;;
      Projects/ExternalInterface/*)
        add_scheme "ExternalInterface"
        add_scheme "Data"
        add_scheme "Jacsim"
        ;;
      Projects/Data/*)
        add_scheme "Data"
        add_scheme "Jacsim"
        ;;
      Projects/Jacsim/*)
        add_scheme "Jacsim"
        ;;
      Projects/Modules/*)
        add_scheme "Jacsim"
        ;;
      Tuist/*|Plugins/*|xcconfigs/*|Workspace.swift|Package.swift|Tuist.swift|.github/workflows/*|scripts/ci/*|scripts/tuist/*)
        fallback_full_suite="true"
        ;;
      *)
        # Unknown non-doc changes can affect build graph or tests.
        fallback_full_suite="true"
        ;;
    esac
  done

  if [[ "${fallback_full_suite}" == "true" ]]; then
    set_full_suite
  fi
fi

selected_count=0
schemes_json="["

for scheme in "${ordered_schemes[@]}"; do
  if [[ "${selected_schemes_csv}" == *",${scheme},"* ]]; then
    if [[ "${selected_count}" -gt 0 ]]; then
      schemes_json+=","
    fi
    schemes_json+="\"${scheme}\""
    ((selected_count += 1))
  fi
done

schemes_json+="]"

if [[ "${non_doc_change_detected}" != "true" || "${selected_count}" -eq 0 ]]; then
  should_run="false"
  schemes_json="[]"
else
  should_run="true"
fi

write_output() {
  local key="$1"
  local value="$2"
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    printf '%s=%s\n' "${key}" "${value}" >> "${GITHUB_OUTPUT}"
  fi
  printf '%s=%s\n' "${key}" "${value}"
}

write_output "should_run" "${should_run}"
write_output "schemes_json" "${schemes_json}"
