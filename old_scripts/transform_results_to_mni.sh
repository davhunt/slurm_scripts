#!/bin/bash

subj=${1}
subj=$(printf "%02d" $subj)

#perm_dir="/N/slate/brainevo/Implicit_Learning/Complex_seq_analysis/0${subj}/MVPA/durations_unsmoothed_native/perm"
results_dir="/N/slate/brainevo/Implicit_Learning/Complex_seq_analysis/0${subj}/MVPA/durations_unsmoothed_native/TDT_results_rad3"
mni_template="$FSLDIR/data/standard/MNI152_T1_2mm.nii.gz"
t1_to_mni_warp="/N/slate/brainevo/Implicit_Learning/ants_mni_registrations/${subj}/t1_to_mni_1Warp.nii.gz"
t1_to_mni_affine="/N/slate/brainevo/Implicit_Learning/ants_mni_registrations/${subj}/t1_to_mni_0GenericAffine.mat"
epi_to_t1_affine="/N/slate/brainevo/Implicit_Learning/ants_mni_registrations/${subj}/epi_to_t1_0GenericAffine.mat"

#echo "applying transform to all permutation accuracy above chance maps for subject ${subj}"
echo "applying transform to all correctly labeled accuracy above chance maps for subject ${subj}"

#antsApplyTransforms -d 3 -i ${accuracy_map_epi} -r ${mni_template} -o ${out_file} -t ${t1_to_mni_warp} -t ${t1_to_mni_affine} -t ${epi_to_t1_affine} --interpolation Linear



for r in $(seq -w 1 10); do
    accuracy_map_epi=${results_dir}/TDT_results_rep${r}/res_accuracy_minus_chance.nii.gz
    out_file=${results_dir}/TDT_results_rep${r}/res_accuracy_minus_chance_mni.nii.gz
    antsApplyTransforms -d 3 -i ${accuracy_map_epi} -r ${mni_template} -o ${out_file} -t ${t1_to_mni_warp} -t ${t1_to_mni_affine} -t ${epi_to_t1_affine} -u float --interpolation Linear
done

# also
accuracy_map_epi_avg=${results_dir}/TDT_results_avg_allreps/res_accuracy_minus_chance.nii.gz
out_file_avg=${results_dir}/TDT_results_avg_allreps/res_accuracy_minus_chance_mni.nii.gz
antsApplyTransforms -d 3 -i ${accuracy_map_epi_avg} -r ${mni_template} -o ${out_file_avg} -t ${t1_to_mni_warp} -t ${t1_to_mni_affine} -t ${epi_to_t1_affine} -u float --interpolation Linear
