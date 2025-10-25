#!/bin/bash
#SBATCH -J cdo_qtr
#SBATCH -p shared
#SBATCH -A bzaitch1
#SBATCH -c 4
#SBATCH --mem=8G
#SBATCH -t 3:59:00
#SBATCH -o logs/%x_%A_%a.out
#SBATCH -e logs/%x_%A_%a.err

set -euo pipefail
module load cdo
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-1}
export HDF5_USE_FILE_LOCKING=FALSE
export NETCDF_HDF5_FILE_LOCKING=FALSE

IN=/vast/bzaitch1/trp_climate_model_data/era5land_1970_2024_hourly
OUT=/vast/bzaitch1/trp_climate_model_data/era5land_1970_2024_qtrmean
mkdir -p "$OUT" logs

IFS=, read -r YEAR QI < <(sed -n "${SLURM_ARRAY_TASK_ID}p" tasks.csv)

case "$QI" in
  1) M1=01; M2=02; M3=03;;
  2) M1=04; M2=05; M3=06;;
  3) M1=07; M2=08; M3=09;;
  4) M1=10; M2=11; M3=12;;
esac

F1="$IN/${YEAR}_${M1}.nc"
F2="$IN/${YEAR}_${M2}.nc"
F3="$IN/${YEAR}_${M3}.nc"
for f in "$F1" "$F2" "$F3"; do
  [[ -s "$f" ]] || { echo "[ERR] Missing $f"; exit 2; }
done

QMEAN="$OUT/${YEAR}_Q${QI}_mean.nc"
QMEAN_PART="${QMEAN}.part.$$"

# If already finished, skip
[[ -s "$QMEAN" ]] && { echo "[SKIP] $QMEAN exists"; exit 0; }

# OPTIONAL: drop ERA5 aux vars (expver/number) to avoid warnings and shrink I/O
# Build variable list once from the first month:
VARS=$(cdo -s showname "$F1" | tr ' ' '\n' | grep -v -E '^(expver|number)$' | paste -sd, -)

# Streamed merge+mean into a temp, then publish atomically
cdo -P ${SLURM_CPUS_PER_TASK:-1} -O -b F32 -z zip_4 \
  timmean -selname,"$VARS" -mergetime "$F1" "$F2" "$F3" "$QMEAN_PART"

# sanity check and publish
ncdump -h "$QMEAN_PART" >/dev/null
mv -f "$QMEAN_PART" "$QMEAN"

echo "[OK] ${YEAR} Q${QI} → $QMEAN"

# Clean up left over
find /vast/bzaitch1/trp_climate_model_data/era5land_1970_2024_qtrmean \
  -maxdepth 1 -type f -name '*_Q*_all.nc.part.*' -print -delete


# run 
# mkdir -p logs
# sbatch --array=1-$(wc -l < tasks.csv)%8 quarter_make.slurm   # at most 8 running at once
