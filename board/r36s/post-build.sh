#!/usr/bin/env bash
# Mesa's Panfrost driver selects the OpenCL "precompiled shader" toolchain
# (BR2_PACKAGE_MESA3D_NEEDS_PRECOMP_COMPILER), which installs clang, libclc,
# SPIRV-LLVM-Translator and the LLVM/SPIRV-Tools utilities on the target.
# The shaders are precompiled on the host and no OpenCL runtime is built, so
# nothing loads them at runtime. libgallium links only libLLVM and
# libSPIRV-Tools, so keep those and drop the rest (about 150 MB).
set -e

TARGET="$1"
FILE_LIST="${BUILD_DIR}/packages-file-list.txt"

awk -F, '
	{ path = substr($0, length($1) + 2) }
	$1 == "clang" || $1 == "libclc" || $1 == "spirv-llvm-translator" { drop[path] = 1; next }
	$1 == "llvm" && path !~ /\/libLLVM(-[0-9]+)?\.so/ { drop[path] = 1; next }
	$1 == "spirv-tools" && path !~ /\/libSPIRV-Tools\.so$/ { drop[path] = 1; next }
	{ keep[path] = 1 }
	END { for (f in drop) if (!(f in keep)) print f }
' "${FILE_LIST}" | while read -r f; do
	rm -f "${TARGET}/${f}"
	rmdir -p --ignore-fail-on-non-empty "$(dirname "${TARGET}/${f}")" 2>/dev/null || true
done
