#!/bin/bash

# Transform native decoding accuracy maps -> MNI (MNI152NLin6Asym)

subj=${1}
subj=$(printf "%02d" $subj)
subfolder=${2}

#perm_dir="/N/slate/brainevo/Implicit_Learning/Complex_seq_analysis/0${subj}/MVPA/${subfolder}/perm"
perm_dir="/N/project/brainevo/Complex_seq_analysis/0${subj}/MVPA/${subfolder}/perm"
mni_template="$FSLDIR/data/standard/MNI152_T1_2mm.nii.gz"
t1_to_mni_warp="/N/slate/brainevo/Implicit_Learning/ants_mni_registrations/${subj}/t1_to_mni_1Warp.nii.gz"
t1_to_mni_affine="/N/slate/brainevo/Implicit_Learning/ants_mni_registrations/${subj}/t1_to_mni_0GenericAffine.mat"
epi_to_t1_affine="/N/slate/brainevo/Implicit_Learning/ants_mni_registrations/${subj}/epi_to_t1_0GenericAffine.mat"

echo "applying MNI transform to all average decoding accuracy maps for sub-${subj}"

#for p in $(seq -w 1 500); do
#for p in $(seq -w 501 999) 1000; do
for p in $(seq -w 1 999) 1000; do
# later 501 - 1000 if we go up to 1000
  #for r in $(seq -w 1 10); do
  #  accuracy_map_epi=${perm_dir}/perm${p}/results_rep${r}/res_accuracy_minus_chance.nii.gz
  #  out_file=${perm_dir}/perm${p}/results_rep${r}/res_accuracy_minus_chance_mni.nii.gz
  #  antsApplyTransforms -d 3 -i ${accuracy_map_epi} -r ${mni_template} -o ${out_file} -t ${t1_to_mni_warp} -t ${t1_to_mni_affine} -t ${epi_to_t1_affine} -u float --interpolation Linear
  #done
  # Also for the averaged image -- does it matter if we average in native then transform, or transform and then average? Probably not? So don't need to transform each rep ^^ just the avg
  accuracy_map_epi=${perm_dir}/perm${p}/results_avg_allreps/res_accuracy_minus_chance.nii.gz
  out_file=${perm_dir}/perm${p}/results_avg_allreps/res_accuracy_minus_chance_mni.nii.gz
  antsApplyTransforms -d 3 -i ${accuracy_map_epi} -r ${mni_template} -o ${out_file} -t ${t1_to_mni_warp} -t ${t1_to_mni_affine} -t ${epi_to_t1_affine} -u float --interpolation Linear
done

echo "done!"
