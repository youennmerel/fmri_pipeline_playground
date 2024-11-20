%-----------------------------------------------------------------------
% Job saved on 19-Nov-2024 17:53:10 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
%%

clear all % clear all variables
clc % clear command window
addpath /home/ymerel/spm12/

%-----------------------------------------------------------------------
% PREPROCESSING
%-----------------------------------------------------------------------

disp('Preprocessing...');

sub_path = '/home/ymerel/fmri_pipeline_playground/spm/face/matlab/data/';

anat_path = fullfile(sub_path, 'Structural');
anat = spm_select('list', anat_path, '.*img');

func_path = fullfile(sub_path, 'RawEPI');
func = spm_select('list', func_path, '.*img');

cd(func_path);

%%% Realign : Estimate & reslice %%%

matlabbatch{1}.spm.spatial.realign.estwrite.data = cellstr(func);
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

matlabbatch{2}.spm.temporal.st.scans{1}(1) = cfg_dep('Realign: Estimate & Reslice: Realigned Images (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','cfiles'));
matlabbatch{2}.spm.temporal.st.nslices = 24;
matlabbatch{2}.spm.temporal.st.tr = 2;
matlabbatch{2}.spm.temporal.st.ta = 1.92;
matlabbatch{2}.spm.temporal.st.so = [24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1];
matlabbatch{2}.spm.temporal.st.refslice = 12;
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
%%% Normalise : Write - Functional %%%

matlabbatch{5}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{5}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
matlabbatch{5}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
matlabbatch{5}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{5}.spm.spatial.normalise.write.woptions.prefix = 'w';

%%% Normalise : Write - Anatomical %%%

matlabbatch{6}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
matlabbatch{6}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Segment: Bias Corrected (1)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','channel', '()',{1}, '.','biascorr', '()',{':'}));
matlabbatch{6}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
matlabbatch{6}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
matlabbatch{6}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{6}.spm.spatial.normalise.write.woptions.prefix = 'w';

%%% Smooth %%%

matlabbatch{7}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{7}.spm.spatial.smooth.fwhm = [8 8 8];
matlabbatch{7}.spm.spatial.smooth.dtype = 0;
matlabbatch{7}.spm.spatial.smooth.im = 0;
matlabbatch{7}.spm.spatial.smooth.prefix = 's';

disp('Preprocessing... Done');

%-----------------------------------------------------------------------
% FIRST LEVEL ANALYSIS - CATEGORICAL
%-----------------------------------------------------------------------

disp('First level Analysis...');

disp('Categorical...');

matlabbatch{8}.spm.stats.fmri_spec.dir = {'/home/ymerel/fmri_pipeline_playground/spm/face/matlab/results/categorical'};
matlabbatch{8}.spm.stats.fmri_spec.timing.units = 'scans';
matlabbatch{8}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{8}.spm.stats.fmri_spec.timing.fmri_t = 24;
matlabbatch{8}.spm.stats.fmri_spec.timing.fmri_t0 = 12;
matlabbatch{8}.spm.stats.fmri_spec.sess.scans(1) = cfg_dep('Smooth: Smoothed Images', substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(1).name = 'N1';
%%
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(1).onset = [6.74996666666667
                                                         15.7499666666667
                                                         17.9999666666667
                                                         26.9999666666667
                                                         29.2499666666667
                                                         31.4999666666667
                                                         35.9999666666667
                                                         42.7499666666667
                                                         65.2499666666667
                                                         67.4999666666667
                                                         74.2499666666667
                                                         92.2499666666667
                                                         112.499966666667
                                                         119.249966666667
                                                         123.749966666667
                                                         125.999966666667
                                                         137.249966666667
                                                         141.749966666667
                                                         143.999966666667
                                                         146.249966666667
                                                         155.249966666667
                                                         159.749966666667
                                                         161.999966666667
                                                         164.249966666667
                                                         204.749966666667
                                                         238.499966666667];
%%
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(1).duration = 0;
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(1).orth = 1;
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(2).name = 'N2';
%%
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(2).onset = [13.4999666666667
                                                         40.4999666666667
                                                         47.2499666666667
                                                         56.2499666666667
                                                         89.9999666666667
                                                         94.4999666666667
                                                         96.7499666666667
                                                         134.999966666667
                                                         148.499966666667
                                                         184.499966666667
                                                         191.249966666667
                                                         202.499966666667
                                                         215.999966666667
                                                         233.999966666667
                                                         236.249966666667
                                                         242.999966666667
                                                         245.249966666667
                                                         256.499966666667
                                                         260.999966666667
                                                         281.249966666667
                                                         290.249966666667
                                                         303.749966666667
                                                         310.499966666667
                                                         319.499966666667
                                                         339.749966666667
                                                         341.999966666667];
%%
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(2).duration = 0;
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(2).orth = 1;
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(3).name = 'F1';
%%
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(3).onset = [-3.33333333333366e-05
                                                         2.24996666666667
                                                         8.99996666666667
                                                         11.2499666666667
                                                         22.4999666666667
                                                         44.9999666666667
                                                         51.7499666666667
                                                         60.7499666666667
                                                         62.9999666666667
                                                         76.4999666666667
                                                         78.7499666666667
                                                         85.4999666666667
                                                         98.9999666666667
                                                         101.249966666667
                                                         103.499966666667
                                                         116.999966666667
                                                         130.499966666667
                                                         150.749966666667
                                                         170.999966666667
                                                         188.999966666667
                                                         227.249966666667
                                                         265.499966666667
                                                         283.499966666667
                                                         285.749966666667
                                                         287.999966666667
                                                         344.249966666667];
%%
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(3).duration = 0;
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(3).orth = 1;
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(4).name = 'F2';
%%
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(4).onset = [33.7499666666667
                                                         49.4999666666667
                                                         105.749966666667
                                                         152.999966666667
                                                         157.499966666667
                                                         168.749966666667
                                                         177.749966666667
                                                         179.999966666667
                                                         182.249966666667
                                                         197.999966666667
                                                         222.749966666667
                                                         240.749966666667
                                                         254.249966666667
                                                         267.749966666667
                                                         269.999966666667
                                                         274.499966666667
                                                         294.749966666667
                                                         299.249966666667
                                                         301.499966666667
                                                         314.999966666667
                                                         317.249966666667
                                                         326.249966666667
                                                         332.999966666667
                                                         335.249966666667
                                                         337.499966666667
                                                         346.499966666667];
%%
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(4).duration = 0;
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{8}.spm.stats.fmri_spec.sess.cond(4).orth = 1;
matlabbatch{8}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{8}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{8}.spm.stats.fmri_spec.sess.multi_reg(1) = cfg_dep('Realign: Estimate & Reslice: Realignment Param File (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rpfile'));
matlabbatch{8}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{8}.spm.stats.fmri_spec.fact(1).name = 'Fam';
matlabbatch{8}.spm.stats.fmri_spec.fact(1).levels = 2;
matlabbatch{8}.spm.stats.fmri_spec.fact(2).name = 'Rep';
matlabbatch{8}.spm.stats.fmri_spec.fact(2).levels = 2;
matlabbatch{8}.spm.stats.fmri_spec.bases.hrf.derivs = [1 1];
matlabbatch{8}.spm.stats.fmri_spec.volt = 1;
matlabbatch{8}.spm.stats.fmri_spec.global = 'None';
matlabbatch{8}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{8}.spm.stats.fmri_spec.mask = {''};
matlabbatch{8}.spm.stats.fmri_spec.cvi = 'AR(1)';

matlabbatch{9}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{8}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{9}.spm.stats.fmri_est.write_residuals = 1;
matlabbatch{9}.spm.stats.fmri_est.method.Classical = 1;

matlabbatch{10}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{10}.spm.stats.con.consess = {};
matlabbatch{10}.spm.stats.con.delete = 0;

%-----------------------------------------------------------------------
% FIRST LEVEL ANALYSIS - PARAMETRIC
%-----------------------------------------------------------------------

disp('Parametric...');

matlabbatch{11}.spm.stats.fmri_spec.dir = {'/home/ymerel/fmri_pipeline_playground/spm/face/matlab/results/parametric'};
matlabbatch{11}.spm.stats.fmri_spec.timing.units = 'scans';
matlabbatch{11}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{11}.spm.stats.fmri_spec.timing.fmri_t = 24;
matlabbatch{11}.spm.stats.fmri_spec.timing.fmri_t0 = 12;
matlabbatch{11}.spm.stats.fmri_spec.sess.scans(1) = cfg_dep('Smooth: Smoothed Images', substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(1).name = 'N1';
%%
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(1).onset = [6.74996666666667
                                                          15.7499666666667
                                                          17.9999666666667
                                                          26.9999666666667
                                                          29.2499666666667
                                                          31.4999666666667
                                                          35.9999666666667
                                                          42.7499666666667
                                                          65.2499666666667
                                                          67.4999666666667
                                                          74.2499666666667
                                                          92.2499666666667
                                                          112.499966666667
                                                          119.249966666667
                                                          123.749966666667
                                                          125.999966666667
                                                          137.249966666667
                                                          141.749966666667
                                                          143.999966666667
                                                          146.249966666667
                                                          155.249966666667
                                                          159.749966666667
                                                          161.999966666667
                                                          164.249966666667
                                                          204.749966666667
                                                          238.499966666667];
%%
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(1).duration = 0;
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(1).orth = 1;
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(2).name = 'N2';
%%
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(2).onset = [13.4999666666667
                                                          40.4999666666667
                                                          47.2499666666667
                                                          56.2499666666667
                                                          89.9999666666667
                                                          94.4999666666667
                                                          96.7499666666667
                                                          134.999966666667
                                                          148.499966666667
                                                          184.499966666667
                                                          191.249966666667
                                                          202.499966666667
                                                          215.999966666667
                                                          233.999966666667
                                                          236.249966666667
                                                          242.999966666667
                                                          245.249966666667
                                                          256.499966666667
                                                          260.999966666667
                                                          281.249966666667
                                                          290.249966666667
                                                          303.749966666667
                                                          310.499966666667
                                                          319.499966666667
                                                          339.749966666667
                                                          341.999966666667];
%%
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(2).duration = 0;
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(2).pmod.name = 'Lag';
%%
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(2).pmod.param = [3
                                                               3
                                                               10
                                                               10
                                                               14
                                                               1
                                                               23
                                                               3
                                                               3
                                                               37
                                                               10
                                                               42
                                                               61
                                                               33
                                                               27
                                                               61
                                                               28
                                                               22
                                                               39
                                                               37
                                                               62
                                                               37
                                                               20
                                                               54
                                                               34
                                                               50];
%%
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(2).pmod.poly = 2;
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(2).orth = 1;
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(3).name = 'F1';
%%
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(3).onset = [-3.33333333333366e-05
                                                          2.24996666666667
                                                          8.99996666666667
                                                          11.2499666666667
                                                          22.4999666666667
                                                          44.9999666666667
                                                          51.7499666666667
                                                          60.7499666666667
                                                          62.9999666666667
                                                          76.4999666666667
                                                          78.7499666666667
                                                          85.4999666666667
                                                          98.9999666666667
                                                          101.249966666667
                                                          103.499966666667
                                                          116.999966666667
                                                          130.499966666667
                                                          150.749966666667
                                                          170.999966666667
                                                          188.999966666667
                                                          227.249966666667
                                                          265.499966666667
                                                          283.499966666667
                                                          285.749966666667
                                                          287.999966666667
                                                          344.249966666667];
%%
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(3).duration = 0;
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(3).orth = 1;
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(4).name = 'F2';
%%
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(4).onset = [33.7499666666667
                                                          49.4999666666667
                                                          105.749966666667
                                                          152.999966666667
                                                          157.499966666667
                                                          168.749966666667
                                                          177.749966666667
                                                          179.999966666667
                                                          182.249966666667
                                                          197.999966666667
                                                          222.749966666667
                                                          240.749966666667
                                                          254.249966666667
                                                          267.749966666667
                                                          269.999966666667
                                                          274.499966666667
                                                          294.749966666667
                                                          299.249966666667
                                                          301.499966666667
                                                          314.999966666667
                                                          317.249966666667
                                                          326.249966666667
                                                          332.999966666667
                                                          335.249966666667
                                                          337.499966666667
                                                          346.499966666667];
%%
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(4).duration = 0;
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(4).pmod.name = 'Lag';
%%
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(4).pmod.param = [11
                                                               14
                                                               2
                                                               47
                                                               36
                                                               18
                                                               37
                                                               59
                                                               11
                                                               56
                                                               33
                                                               4
                                                               57
                                                               18
                                                               59
                                                               55
                                                               46
                                                               61
                                                               4
                                                               67
                                                               9
                                                               63
                                                               13
                                                               19
                                                               42
                                                               1];
%%
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(4).pmod.poly = 2;
matlabbatch{11}.spm.stats.fmri_spec.sess.cond(4).orth = 1;
matlabbatch{11}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{11}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{11}.spm.stats.fmri_spec.sess.multi_reg(1) = cfg_dep('Realign: Estimate & Reslice: Realignment Param File (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rpfile'));
matlabbatch{11}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{11}.spm.stats.fmri_spec.fact(1).name = 'Fam';
matlabbatch{11}.spm.stats.fmri_spec.fact(1).levels = 2;
matlabbatch{11}.spm.stats.fmri_spec.fact(2).name = 'Rep';
matlabbatch{11}.spm.stats.fmri_spec.fact(2).levels = 2;
matlabbatch{11}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{11}.spm.stats.fmri_spec.volt = 1;
matlabbatch{11}.spm.stats.fmri_spec.global = 'None';
matlabbatch{11}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{11}.spm.stats.fmri_spec.mask = {''};
matlabbatch{11}.spm.stats.fmri_spec.cvi = 'AR(1)';

matlabbatch{12}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{11}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{12}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{12}.spm.stats.fmri_est.method.Classical = 1;

matlabbatch{13}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{12}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{13}.spm.stats.con.consess{1}.fcon.name = 'Famous Lag';
matlabbatch{13}.spm.stats.con.consess{1}.fcon.weights = [1 2 3 4 5 6 9 10 11 12 13 14 15];
matlabbatch{13}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
matlabbatch{13}.spm.stats.con.delete = 0;

%-----------------------------------------------------------------------
% FIRST LEVEL ANALYSIS - BAYESIAN
%-----------------------------------------------------------------------

disp('Bayesian...');

matlabbatch{14}.spm.stats.fmri_spec.dir = {'/home/ymerel/fmri_pipeline_playground/spm/face/matlab/results/bayesian'};
matlabbatch{14}.spm.stats.fmri_spec.timing.units = 'scans';
matlabbatch{14}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{14}.spm.stats.fmri_spec.timing.fmri_t = 24;
matlabbatch{14}.spm.stats.fmri_spec.timing.fmri_t0 = 12;
matlabbatch{14}.spm.stats.fmri_spec.sess.scans(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(1).name = 'N1';
%%
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(1).onset = [6.74996666666667
                                                          15.7499666666667
                                                          17.9999666666667
                                                          26.9999666666667
                                                          29.2499666666667
                                                          31.4999666666667
                                                          35.9999666666667
                                                          42.7499666666667
                                                          65.2499666666667
                                                          67.4999666666667
                                                          74.2499666666667
                                                          92.2499666666667
                                                          112.499966666667
                                                          119.249966666667
                                                          123.749966666667
                                                          125.999966666667
                                                          137.249966666667
                                                          141.749966666667
                                                          143.999966666667
                                                          146.249966666667
                                                          155.249966666667
                                                          159.749966666667
                                                          161.999966666667
                                                          164.249966666667
                                                          204.749966666667
                                                          238.499966666667];
%%
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(1).duration = 0;
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(1).orth = 1;
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(2).name = 'N2';
%%
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(2).onset = [13.4999666666667
                                                          40.4999666666667
                                                          47.2499666666667
                                                          56.2499666666667
                                                          89.9999666666667
                                                          94.4999666666667
                                                          96.7499666666667
                                                          134.999966666667
                                                          148.499966666667
                                                          184.499966666667
                                                          191.249966666667
                                                          202.499966666667
                                                          215.999966666667
                                                          233.999966666667
                                                          236.249966666667
                                                          242.999966666667
                                                          245.249966666667
                                                          256.499966666667
                                                          260.999966666667
                                                          281.249966666667
                                                          290.249966666667
                                                          303.749966666667
                                                          310.499966666667
                                                          319.499966666667
                                                          339.749966666667
                                                          341.999966666667];
%%
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(2).duration = 0;
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(2).orth = 1;
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(3).name = 'F1';
%%
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(3).onset = [-3.33333333333366e-05
                                                          2.24996666666667
                                                          8.99996666666667
                                                          11.2499666666667
                                                          22.4999666666667
                                                          44.9999666666667
                                                          51.7499666666667
                                                          60.7499666666667
                                                          62.9999666666667
                                                          76.4999666666667
                                                          78.7499666666667
                                                          85.4999666666667
                                                          98.9999666666667
                                                          101.249966666667
                                                          103.499966666667
                                                          116.999966666667
                                                          130.499966666667
                                                          150.749966666667
                                                          170.999966666667
                                                          188.999966666667
                                                          227.249966666667
                                                          265.499966666667
                                                          283.499966666667
                                                          285.749966666667
                                                          287.999966666667
                                                          344.249966666667];
%%
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(3).duration = 0;
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(3).orth = 1;
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(4).name = 'F2';
%%
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(4).onset = [33.7499666666667
                                                          49.4999666666667
                                                          105.749966666667
                                                          152.999966666667
                                                          157.499966666667
                                                          168.749966666667
                                                          177.749966666667
                                                          179.999966666667
                                                          182.249966666667
                                                          197.999966666667
                                                          222.749966666667
                                                          240.749966666667
                                                          254.249966666667
                                                          267.749966666667
                                                          269.999966666667
                                                          274.499966666667
                                                          294.749966666667
                                                          299.249966666667
                                                          301.499966666667
                                                          314.999966666667
                                                          317.249966666667
                                                          326.249966666667
                                                          332.999966666667
                                                          335.249966666667
                                                          337.499966666667
                                                          346.499966666667];
%%
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(4).duration = 0;
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{14}.spm.stats.fmri_spec.sess.cond(4).orth = 1;
matlabbatch{14}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{14}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{14}.spm.stats.fmri_spec.sess.multi_reg(1) = cfg_dep('Realign: Estimate & Reslice: Realignment Param File (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rpfile'));
matlabbatch{14}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{14}.spm.stats.fmri_spec.fact(1).name = 'Fam';
matlabbatch{14}.spm.stats.fmri_spec.fact(1).levels = 2;
matlabbatch{14}.spm.stats.fmri_spec.fact(2).name = 'Rep';
matlabbatch{14}.spm.stats.fmri_spec.fact(2).levels = 2;
matlabbatch{14}.spm.stats.fmri_spec.bases.hrf.derivs = [1 1];
matlabbatch{14}.spm.stats.fmri_spec.volt = 1;
matlabbatch{14}.spm.stats.fmri_spec.global = 'None';
matlabbatch{14}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{14}.spm.stats.fmri_spec.mask = {''};
matlabbatch{14}.spm.stats.fmri_spec.cvi = 'AR(1)';

matlabbatch{15}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{14}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{15}.spm.stats.fmri_est.write_residuals = 1;
matlabbatch{15}.spm.stats.fmri_est.method.Bayesian.space.volume.block_type = 'Slices';
matlabbatch{15}.spm.stats.fmri_est.method.Bayesian.signal = 'UGL';
matlabbatch{15}.spm.stats.fmri_est.method.Bayesian.ARP = 3;
matlabbatch{15}.spm.stats.fmri_est.method.Bayesian.noise.UGL = 1;
matlabbatch{15}.spm.stats.fmri_est.method.Bayesian.LogEv = 'No';
matlabbatch{15}.spm.stats.fmri_est.method.Bayesian.anova.first = 'No';
matlabbatch{15}.spm.stats.fmri_est.method.Bayesian.anova.second = 'Yes';
matlabbatch{15}.spm.stats.fmri_est.method.Bayesian.gcon = struct('name', {}, 'convec', {});

matlabbatch{16}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{15}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{16}.spm.stats.con.consess{1}.tcon.name = 'AVERAGE Canonical HRF: Faces $>$';
matlabbatch{16}.spm.stats.con.consess{1}.tcon.weights = [0.25 0 0 0.25 0 0 0.25 0 0 0.25 0 0];
matlabbatch{16}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{16}.spm.stats.con.delete = 0;

disp('First level Analysis... Done');

clear matlabbatch % clear matlabbatch
