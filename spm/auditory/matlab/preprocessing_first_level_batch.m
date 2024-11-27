%-----------------------------------------------------------------------
% Job saved on 21-Oct-2024 15:15:23 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

clear all % clear all variables
clc % clear command window
addpath /home/ymerel/spm12/

data = '/home/ymerel/fmri_pipeline_playground/spm/auditory/matlab/data/' % path to BIDS data
results = '/home/ymerel/fmri_pipeline_playground/spm/auditory/matlab/results' % path to 1st level analysis results

subjects = {'sub-01'} % subject to process

tr = 7

for i = 1:numel(subjects)

    sub = subjects{i};

    disp(['Starting preprocessing for ', sub]);

    sub_path = strcat(data, '/', sub);

    anat_path = fullfile(sub_path, 'anat')
    % this will return the full path (FP) to the T1 file from the anat directory
    anat = spm_select('FPList', anat_path, '^sub-*.*_T1w.nii$')

    func_path = fullfile(sub_path, 'func')
    % this will give the full path to the task data, NaN will ensure you are loading all volumes present (i.e. consider the 4D file as a whole)
    func = spm_select('ExtFPList', func_path, '^sub-*.*_task-auditory_bold.nii$', NaN)
    cd(func_path) % move into the subject specific folder containing the functional data

    disp(['Moved to ', func_path]);

    %-----------------------------------------------------------------------
    % PREPROCESSING
    %-----------------------------------------------------------------------

    %%% Realign : Estimate & reslice %%%

    matlabbatch{1}.spm.spatial.realign.estwrite.data{1} = cellstr(func); % point the batch to the func variable
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

    %%% Slice timing %%%

    matlabbatch{2}.spm.temporal.st.scans{1}(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rfiles'));
    matlabbatch{2}.spm.temporal.st.nslices = 64;
    matlabbatch{2}.spm.temporal.st.tr = tr;
    matlabbatch{2}.spm.temporal.st.ta = 6.8906;
    matlabbatch{2}.spm.temporal.st.so = [64 63 62 61 60 59 58 57 56 55 54 53 52 51 50 49 48 47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1];
    matlabbatch{2}.spm.temporal.st.refslice = 32;
    matlabbatch{2}.spm.temporal.st.prefix = 'a';

    %%% Coregister : estimate %%%

    matlabbatch{3}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
    matlabbatch{3}.spm.spatial.coreg.estimate.source = cellstr(anat);
    matlabbatch{3}.spm.spatial.coreg.estimate.other = {''};
    matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

    %%% Segment %%%

    matlabbatch{4}.spm.spatial.preproc.channel.vols(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
    matlabbatch{4}.spm.spatial.preproc.channel.biasreg = 0.001;
    matlabbatch{4}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{4}.spm.spatial.preproc.channel.write = [0 1];
    matlabbatch{4}.spm.spatial.preproc.tissue(1).tpm = {'/home/ymerel/spm12/tpm/TPM.nii,1'};
    matlabbatch{4}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{4}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(2).tpm = {'/home/ymerel/spm12/tpm/TPM.nii,2'};
    matlabbatch{4}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{4}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(3).tpm = {'/home/ymerel/spm12/tpm/TPM.nii,3'};
    matlabbatch{4}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{4}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(4).tpm = {'/home/ymerel/spm12/tpm/TPM.nii,4'};
    matlabbatch{4}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{4}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(5).tpm = {'/home/ymerel/spm12/tpm/TPM.nii,5'};
    matlabbatch{4}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{4}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(6).tpm = {'/home/ymerel/spm12/tpm/TPM.nii,6'};
    matlabbatch{4}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{4}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{4}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{4}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{4}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{4}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{4}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{4}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{4}.spm.spatial.preproc.warp.write = [0 1];
    matlabbatch{4}.spm.spatial.preproc.warp.vox = NaN;
    matlabbatch{4}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                                  NaN NaN NaN];

    %%% Normalise : Write %%%

    matlabbatch{5}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
    matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
    matlabbatch{5}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                              78 76 85];
    matlabbatch{5}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
    matlabbatch{5}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{5}.spm.spatial.normalise.write.woptions.prefix = 'w';

    %%% Smooth %%%

    matlabbatch{6}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
    matlabbatch{6}.spm.spatial.smooth.fwhm = [6 6 6];
    matlabbatch{6}.spm.spatial.smooth.dtype = 0;
    matlabbatch{6}.spm.spatial.smooth.im = 0;
    matlabbatch{6}.spm.spatial.smooth.prefix = 's';

    %%% fMRI model specification %%%

    matlabbatch{7}.spm.stats.fmri_spec.dir = {results};
    matlabbatch{7}.spm.stats.fmri_spec.timing.units = 'scans';
    matlabbatch{7}.spm.stats.fmri_spec.timing.RT = 7;
    matlabbatch{7}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{7}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
    matlabbatch{7}.spm.stats.fmri_spec.sess.scans(1) = cfg_dep('Smooth: Smoothed Images', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
    matlabbatch{7}.spm.stats.fmri_spec.sess.cond.name = 'listening';
    matlabbatch{7}.spm.stats.fmri_spec.sess.cond.onset = [6
                                                          18
                                                          30
                                                          42
                                                          54
                                                          66
                                                          78];
    matlabbatch{7}.spm.stats.fmri_spec.sess.cond.duration = 6;
    matlabbatch{7}.spm.stats.fmri_spec.sess.cond.tmod = 0;
    matlabbatch{7}.spm.stats.fmri_spec.sess.cond.pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{7}.spm.stats.fmri_spec.sess.cond.orth = 1;
    matlabbatch{7}.spm.stats.fmri_spec.sess.multi = {''};
    matlabbatch{7}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{7}.spm.stats.fmri_spec.sess.multi_reg = {''};
    matlabbatch{7}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{7}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{7}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{7}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{7}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{7}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{7}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{7}.spm.stats.fmri_spec.cvi = 'AR(1)';

    %%% Model estimation %%%

    matlabbatch{8}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{8}.spm.stats.fmri_est.write_residuals = 1;
    matlabbatch{8}.spm.stats.fmri_est.method.Classical = 1;

    %%% Contrast manager %%%

    matlabbatch{9}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{8}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{9}.spm.stats.con.consess{1}.tcon.name = 'listening > rest';
    matlabbatch{9}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{9}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{9}.spm.stats.con.consess{2}.tcon.name = 'rest > listening';
    matlabbatch{9}.spm.stats.con.consess{2}.tcon.weights = -1;
    matlabbatch{9}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{9}.spm.stats.con.delete = 0;

    %%% Result report %%%

    % spm('defaults','FMRI');
    % matlabbatch{10}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    % matlabbatch{10}.spm.stats.results.conspec.titlestr = '';
    % matlabbatch{10}.spm.stats.results.conspec.contrasts = Inf;
    % matlabbatch{10}.spm.stats.results.conspec.threshdesc = 'FWE';
    % matlabbatch{10}.spm.stats.results.conspec.thresh = 0.05;
    % matlabbatch{10}.spm.stats.results.conspec.extent = 0;
    % matlabbatch{10}.spm.stats.results.conspec.conjunction = 1;
    % matlabbatch{10}.spm.stats.results.conspec.mask.none = 1;
    % matlabbatch{10}.spm.stats.results.units = 1;
    % matlabbatch{10}.spm.stats.results.export{1}.ps = true;

    save preprocessing_batch matlabbatch % save the setup into a matfile called preprocessing_batch.mat

    disp(['Preprocessing + 1st level analysis ', sub, '...'])
    spm_jobman('run', matlabbatch) % execute the batch
    disp(['Completed preprocessing + 1st level analysis ', sub])

    clear matlabbatch % clear matlabbatch

end