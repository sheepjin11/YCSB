#!/bin/bash

# =========================================
# Global settings
# =========================================

YCSB_DIR="$HOME/YCSB-C"
NVME_DIR="/mnt/nvme"
YCSBC_BIN="${YCSB_DIR}/ycsbc"
THREADS=32

# Add SplinterDB library path
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"

# =========================================
# Helpers
# =========================================

# Convert recordcount to suffix like "84M" or "50k"
format_suffix() {
  local rc="$1"
  awk -v rc="$rc" '
    BEGIN {
      if (rc >= 1000000 && rc % 1000000 == 0)
        printf "%dM", rc/1000000;
      else if (rc >= 1000 && rc % 1000 == 0)
        printf "%dk", rc/1000;
      else
        printf "%s", rc;
    }'
}

# Estimate logical dataset size in GiB (key + value)
estimate_dataset_gib() {
  local rc="$1"
  local key_bytes="$2"
  local value_bytes="$3"
  awk -v rc="$rc" -v kb="$key_bytes" -v vb="$value_bytes" '
    BEGIN {
      total = rc * (kb + vb);
      gib = total / (1024.0*1024.0*1024.0);
      printf "%.2f", gib;
    }'
}

# =========================================
# Core runner: profile = K24BV100B or K24BV1024B
# =========================================
run_for_profile() {
  local PROFILE="$1"       # K24BV100B or K24BV1024B
  local VALUE_BYTES="$2"   # 100 or 1024

  local WORKLOAD_DIR="${YCSB_DIR}/workloads/${PROFILE}"
  local LOAD_SPEC="${WORKLOAD_DIR}/load.spec"

  # Read recordcount from load spec
  local RECORDCOUNT
  RECORDCOUNT=$(grep -E '^recordcount=' "${LOAD_SPEC}" | cut -d'=' -f2)

  if [ -z "$RECORDCOUNT" ]; then
    echo "[ERROR] recordcount not found in ${LOAD_SPEC}"
    return 1
  fi

  local SUFFIX
  SUFFIX=$(format_suffix "$RECORDCOUNT")

  local BASE_DB="${NVME_DIR}/splinterdb_${PROFILE}_${SUFFIX}.db"
  local COPY_DB="${NVME_DIR}/splinterdb_${PROFILE}_${SUFFIX}_copy.db"

  local DATASET_GIB
  DATASET_GIB=$(estimate_dataset_gib "$RECORDCOUNT" 24 "$VALUE_BYTES")

  echo "=================================================="
  echo "[INFO] Profile       : ${PROFILE}"
  echo "[INFO] Value bytes   : ${VALUE_BYTES}"
  echo "[INFO] Load spec     : ${LOAD_SPEC}"
  echo "[INFO] recordcount   : ${RECORDCOUNT}"
  echo "[INFO] Est. dataset  : ~${DATASET_GIB} GiB (logical key+value payload)"
  echo "[INFO] BASE_DB       : ${BASE_DB}"
  echo "=================================================="

  # -------- load base DB --------
  echo "==============================================="
  echo "[LOAD] Creating base DB at: ${BASE_DB}"
  echo "==============================================="

  if [ -f "${BASE_DB}" ]; then
    echo "[WARN] Base DB exists, removing it."
    rm -f "${BASE_DB}"
  fi

  "${YCSBC_BIN}" -db splinterdb -threads "${THREADS}" \
    -L "${LOAD_SPEC}" \
    -p splinterdb.filename "${BASE_DB}"

  # Inner helper for one workload
  run_one_workload() {
    local wl_name="$1"
    local wl_file="$2"

    echo "==============================================="
    echo "[RUN] Workload ${wl_name} (${PROFILE})"
    echo "Copy DB: ${COPY_DB} from Load spec     : ${LOAD_SPEC}"
    echo "Spec   : ${WORKLOAD_DIR}/${wl_file}"
    echo "==============================================="

    rm -f "${COPY_DB}"
    cp "${BASE_DB}" "${COPY_DB}"

    "${YCSBC_BIN}" -db splinterdb -threads "${THREADS}" \
      -P "${LOAD_SPEC}" \
      -W "${WORKLOAD_DIR}/${wl_file}" \
      -p splinterdb.filename "${COPY_DB}"

    echo "[CLEANUP] Removing ${COPY_DB}"
    rm -f "${COPY_DB}"
  }

  # -------- run A~F on copy DB --------
  run_one_workload "A" "workloada.spec"
  run_one_workload "B" "workloadb.spec"
  run_one_workload "C" "workloadc.spec"
  run_one_workload "D" "workloadd.spec"
  run_one_workload "E" "workloade.spec"
  run_one_workload "F" "workloadf.spec"
}

# =========================================
# Main
# Usage: ./run_ycsb_all.sh [100|1024|all]
# =========================================

MODE="${1:-all}"

case "$MODE" in
  100)
    run_for_profile "K24BV100B" 100
    ;;
  1024)
    run_for_profile "K24BV1024B" 1024
    ;;
  all)
    run_for_profile "K24BV100B" 100
    run_for_profile "K24BV1024B" 1024
    ;;
  *)
    echo "Usage: $0 [100|1024|all]"
    exit 1
    ;;
esac

