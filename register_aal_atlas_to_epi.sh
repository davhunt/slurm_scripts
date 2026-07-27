#!/bin/bash

# Get the AAL atlas into subject's native (EPI/fMRI) space

subj=${1}
subj=$(printf "%02d" $subj)

if [[ -z $FSLDIR ]]; then
  echo "env var FSLDIR is not defined, exiting."
  exit
fi

work_dir=/N/slate/brainevo/Implicit_Learning/aal_register_epi/${subj}

t1=${work_dir}/T1w.nii.gz
t1_brain=${work_dir}/T1w_brain.nii.gz
epi=${work_dir}/func_cat.nii.gz
epi_mean=${work_dir}/func_cat_mean.nii.gz
t1_mni=$FSLDIR/data/standard/MNI152_T1_2mm.nii.gz # 2006 tpl-MNI152NLin6Asym
t1_mni_brain=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz
atlas_mni=/N/slate/brainevo/Implicit_Learning/aal_register_epi/aal116MNI.nii.gz # tpl-MNIColin27


#antsBrainExtraction.sh -d 3 -a /Volumes/data1/Complex_seq_analysis/001/MVPA/durations_unsmoothed/T1w.nii.gz -e /Users/lab/Downloads/Ants_Brain_Templates/MICCAI2012-Multi-Atlas-Challenge-Data/T_template0.nii.gz -m /Users/lab/Downloads/Ants_Brain_Templates/MICCAI2012-Multi-Atlas-Challenge-Data/T_template0_BrainCerebellumProbabilityMask.nii.gz -o /Volumes/data1/Complex_seq_analysis/001/MVPA/durations_unsmoothed/ANTS_output -f /Users/lab/Downloads/Ants_Brain_Templates/MICCAI2012-Multi-Atlas-Challenge-Data/T_template0_BrainCerebellumRegistrationMask.nii.gz

echo "doing antsBrainExtraction"
time antsBrainExtraction.sh -d 3 -a /N/slate/brainevo/Implicit_Learning/aal_register_epi/${subj}/T1w.nii.gz -e /N/slate/brainevo/Implicit_Learning/ants_brain_templates/MICCAI2012-Multi-Atlas-Challenge-Data/T_template0.nii.gz -m /N/slate/brainevo/Implicit_Learning/ants_brain_templates/MICCAI2012-Multi-Atlas-Challenge-Data/T_template0_BrainCerebellumProbabilityMask.nii.gz -o /N/slate/brainevo/Implicit_Learning/aal_register_epi/${subj}/ANTS_output -f /N/slate/brainevo/Implicit_Learning/ants_brain_templates/MICCAI2012-Multi-Atlas-Challenge-Data/T_template0_BrainCerebellumRegistrationMask.nii.gz

#mv /N/slate/brainevo/Implicit_Learning/aal_register_epi/${subj}/T1w_brain.nii.gz /N/slate/brainevo/Implicit_Learning/aal_register_epi/${subj}/T1w_brain_bad.nii.gz

cp /N/slate/brainevo/Implicit_Learning/aal_register_epi/${subj}/ANTS_outputBrainExtractionBrain.nii.gz /N/slate/brainevo/Implicit_Learning/aal_register_epi/${subj}/T1w_brain.nii.gz


echo "doing epi_reg"
time epi_reg --epi=${epi_mean} --t1=${t1} --t1brain=${t1_brain} --out=${work_dir}/epi_to_t1
#real	11m6.204s

echo "doing flirt"
time flirt -in ${t1_brain} -ref ${t1_mni_brain} -out ${work_dir}/t1_to_mni_linear.nii.gz -omat ${work_dir}/t1_to_mni.mat
#real	1m8.241s

echo "doing fnirt"
time fnirt --in=${t1} --ref=${t1_mni} --aff=${work_dir}/t1_to_mni.mat --iout=${work_dir}/warped_t1 --cout=${work_dir}/t1_to_mni_warp
#real	24m30.027s

echo "doing invwarp"
time invwarp -w ${work_dir}/t1_to_mni_warp.nii.gz -o ${work_dir}/mni_to_t1_warp.nii.gz -r ${t1}
#real   39m36.147s
convert_xfm -omat ${work_dir}/t1_to_epi.mat -inverse ${work_dir}/epi_to_t1.mat

echo "doing applywarp"
#time applywarp --ref=${epi_mean} --in=${atlas_mni} --out=${work_dir}/aal116_epi_space.nii.gz --warp=${work_dir}/mni_to_t1_warp.nii.gz --postmat=${work_dir}/t1_to_epi.mat
time applywarp --ref=${epi_mean} --in=${atlas_mni} --out=${work_dir}/aal116_epi_space.nii.gz --warp=${work_dir}/mni_to_t1_warp.nii.gz --postmat=${work_dir}/t1_to_epi.mat --interp=nn
#real	1m6.699s
echo "done"
