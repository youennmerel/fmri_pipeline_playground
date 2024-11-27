import hashlib
import os
from builtins import range

import nipype.algorithms.modelgen as model  # model specification
import nipype.interfaces.matlab as mlab  # how to run matlab
import nipype.interfaces.spm as spm  # spm
import nipype.pipeline.engine as pe  # pypeline engine
import scipy
from nipype import IdentityInterface, SelectFiles, DataSink
from nipype.interfaces.base import Bunch

from common.utils import print_correlation, print_file_compare

matlab_path = '/home/ymerel/matlab/bin/matlab'
matlab_cmd = matlab_path + " -nodesktop -nosplash"
spm_path = '/home/ymerel/spm12/'

# Matlab command line
mlab.MatlabCommand.set_default_matlab_cmd(matlab_cmd)
# set SPM path into matlab
mlab.MatlabCommand.set_default_paths(os.path.abspath(spm_path))

# http://www.fil.ion.ucl.ac.uk/spm/data/auditory/
data_dir = os.path.abspath('/home/ymerel/fmri_pipeline_playground/spm/face/nipype/data')
results_dir = os.path.abspath('/home/ymerel/fmri_pipeline_playground/spm/face/nipype/results')
work_dir = os.path.abspath('/home/ymerel/fmri_pipeline_playground/spm/face/nipype/work')

slices_nb = 24
tr = 2
units = 'scans'


def get_categorical_conditions():
    sots = scipy.io.loadmat(data_dir + '/sots.mat', mat_dtype=True, matlab_compatible=True, struct_as_record=True,
                            simplify_cells=True)
    n1_onsets = sots['sot'][0]
    n2_onsets = sots['sot'][1]
    f1_onsets = sots['sot'][2]
    f2_onsets = sots['sot'][3]

    lags = None

    conditions = [
        Bunch(
            conditions=['N1', 'N2', 'F1', 'F2'],
            onsets=[n1_onsets, n2_onsets, f1_onsets, f2_onsets],
            durations=[[0], [0], [0], [0]],
            amplitudes=None,
            tmod=None,
            pmod=lags,
            regressor_names=None,
            regressors=None)
    ]

    return conditions


def get_parametric_conditions():
    sots = scipy.io.loadmat(data_dir + '/sots.mat', mat_dtype=True, matlab_compatible=True, struct_as_record=True,
                            simplify_cells=True)
    n1_onsets = sots['sot'][0]
    n2_onsets = sots['sot'][1]
    n2_lag = sots['itemlag'][1]
    f1_onsets = sots['sot'][2]
    f2_onsets = sots['sot'][3]
    f2_lag = sots['itemlag'][3]

    lags = [
        None,
        Bunch(
            name='Lag',
            poly=2,
            param=n2_lag),
        None,
        Bunch(
            name='Lag',
            poly=2,
            param=f2_lag)
    ]

    conditions = [
        Bunch(
            conditions=['N1', 'N2', 'F1', 'F2'],
            onsets=[n1_onsets, n2_onsets, f1_onsets, f2_onsets],
            durations=[[0], [0], [0], [0]],
            amplitudes=None,
            tmod=None,
            pmod=lags,
            regressor_names=None,
            regressors=None)
    ]

    return conditions


def get_parametric_contrasts():

    cond1 = ('positive effect of condition', 'T',
             ['N1*bf(1)', 'N2*bf(1)', 'F1*bf(1)', 'F2*bf(1)'], [1, 1, 1, 1])
    cond2 = ('positive effect of condition_dtemo', 'T',
             ['N1*bf(2)', 'N2*bf(2)', 'F1*bf(2)', 'F2*bf(2)'], [1, 1, 1, 1])
    cond3 = ('positive effect of condition_ddisp', 'T',
             ['N1*bf(3)', 'N2*bf(3)', 'F1*bf(3)', 'F2*bf(3)'], [1, 1, 1, 1])

    # non-famous > famous
    fam1 = ('positive effect of Fame', 'T',
            ['N1*bf(1)', 'N2*bf(1)', 'F1*bf(1)', 'F2*bf(1)'], [1, 1, -1, -1])
    fam2 = ('positive effect of Fame_dtemp', 'T',
            ['N1*bf(2)', 'N2*bf(2)', 'F1*bf(2)', 'F2*bf(2)'], [1, 1, -1, -1])
    fam3 = ('positive effect of Fame_ddisp', 'T',
            ['N1*bf(3)', 'N2*bf(3)', 'F1*bf(3)', 'F2*bf(3)'], [1, 1, -1, -1])

    # rep1 > rep2
    rep1 = ('positive effect of Rep', 'T',
            ['N1*bf(1)', 'N2*bf(1)', 'F1*bf(1)', 'F2*bf(1)'], [1, -1, 1, -1])
    rep2 = ('positive effect of Rep_dtemp', 'T',
            ['N1*bf(2)', 'N2*bf(2)', 'F1*bf(2)', 'F2*bf(2)'], [1, -1, 1, -1])
    rep3 = ('positive effect of Rep_ddisp', 'T',
            ['N1*bf(3)', 'N2*bf(3)', 'F1*bf(3)', 'F2*bf(3)'], [1, -1, 1, -1])
    int1 = ('positive interaction of Fame x Rep', 'T',
            ['N1*bf(1)', 'N2*bf(1)', 'F1*bf(1)', 'F2*bf(1)'], [-1, -1, -1, 1])
    int2 = ('positive interaction of Fame x Rep_dtemp', 'T',
            ['N1*bf(2)', 'N2*bf(2)', 'F1*bf(2)', 'F2*bf(2)'], [1, -1, -1, 1])
    int3 = ('positive interaction of Fame x Rep_ddisp', 'T',
            ['N1*bf(3)', 'N2*bf(3)', 'F1*bf(3)', 'F2*bf(3)'], [1, -1, -1, 1])

    contf1 = ['average effect condition', 'F', [cond1, cond2, cond3]]
    contf2 = ['main effect Fam', 'F', [fam1, fam2, fam3]]
    contf3 = ['main effect Rep', 'F', [rep1, rep2, rep3]]
    contf4 = ['interaction: Fam x Rep', 'F', [int1, int2, int3]]

    return [
        cond1, cond2, cond3, fam1, fam2, fam3, rep1, rep2, rep3, int1, int2, int3,
        contf1, contf2, contf3, contf4
    ]


def get_categorical_contrasts():
    cont1 = ('Famous_lag1', 'T', ['F2xLag^1'], [1])
    cont2 = ('Famous_lag2', 'T', ['F2xLag^2'], [1])
    fcont1 = ('Famous Lag', 'F', [cont1, cont2])
    return [cont1, cont2, fcont1]

def get_bayesian_contrasts():
    cond1 = ('AVERAGE Canonical HRF: Faces $>$', 'T', [0.25, 0, 0, 0.25, 0, 0, 0.25, 0, 0, 0.25, 0, 0])
    return [cond1]

def get_input():
    templates = {'anat': os.path.join(data_dir, 'Structural', '*.img'),
                 'func': os.path.join(data_dir, 'RawEPI', '*.img')}
    return pe.Node(SelectFiles(templates, base_directory=data_dir), name="input")


def get_output():
    return pe.Node(DataSink(base_directory=results_dir), name="output")


def get_pipeline():
    preproc = get_preprocessing()
    categorical = get_subject_analysis_categorical()
    parametric = get_subject_analysis_parametric()
    bayesian = get_subject_analysis_bayesian()

    pipeline = pe.Workflow(name='Preprocessing_1st_Level_Analysis')
    pipeline.base_dir = work_dir
    pipeline.connect([(preproc, categorical,
                       [
                           ('Realign_Estimate_Reslice.realignment_parameters',
                            'Specify_1st_level_Categorical.realignment_parameters'),
                           (('Smooth.smoothed_files', makelist), 'Specify_1st_level_Categorical.functional_runs')]
                       ),
                      (preproc, parametric,
                       [
                           ('Realign_Estimate_Reslice.realignment_parameters',
                            'Specify_1st_level_Parametric.realignment_parameters'),
                           (('Smooth.smoothed_files', makelist), 'Specify_1st_level_Parametric.functional_runs')]
                       ),
                      (preproc, bayesian,
                       [
                           ('Realign_Estimate_Reslice.realignment_parameters',
                            'Specify_1st_level_Bayesian.realignment_parameters'),
                           (('Smooth.smoothed_files', makelist), 'Specify_1st_level_Bayesian.functional_runs')]
                       )
                      ])

    return pipeline


def makelist(item):
    return [item]


def get_preprocessing():
    preproc = pe.Workflow(name='Preprocessing')

    realign = pe.Node(interface=spm.Realign(), name="Realign_Estimate_Reslice")
    realign.inputs.jobtype = 'estwrite'
    ## Default values :
    ## ---
    # realign.inputs.quality = 0.9
    # realign.inputs.separation = 4
    # realign.inputs.fwhm = 5
    # realign.inputs.register_to_mean = True
    # realign.inputs.interp = 2
    # realign.inputs.wrap = [0, 0, 0]
    # realign.inputs.write_which = [2, 1]
    # realign.inputs.write_interp = 4
    # realign.inputs.write_wrap = [0, 0, 0]
    # realign.inputs.write_mask = True
    ## ---

    sliceTiming = pe.Node(interface=spm.SliceTiming(), name="Slice_Timing")
    sliceTiming.inputs.num_slices = slices_nb
    sliceTiming.inputs.time_repetition = tr
    sliceTiming.inputs.time_acquisition = tr - (tr / slices_nb)
    sliceTiming.inputs.slice_order = list(range(slices_nb, 0, -1))  # [24 23 22 ... 3 2 1]
    sliceTiming.inputs.ref_slice = slices_nb / 2

    coregister = pe.Node(interface=spm.Coregister(), name="Coregister_Estimate")
    coregister.inputs.jobtype = 'estimate'

    segment = pe.Node(interface=spm.NewSegment(), name="Segment")
    # channel.biasreg, channel.biasfwhm, channel.write (Field, Corrected)
    segment.inputs.channel_info = (0.001, 60.0, (False, True))
    segment.inputs.write_deformation_fields = [False, True]
    ## Default values :
    ## ---
    # tpm_file = os.path.abspath(os.path.join(spm_path, 'tpm/TPM.nii'))
    # tissue1 = (tpm_file, 1), 1, (True, False), (False, False)
    # tissue2 = (tpm_file, 2), 1, (True, False), (False, False)
    # tissue3 = (tpm_file, 3), 2, (True, False), (False, False)
    # tissue4 = (tpm_file, 4), 3, (True, False), (False, False)
    # tissue5 = (tpm_file, 5), 4, (True, False), (False, False)
    # tissue6 = (tpm_file, 6), 2, (False, False), (False, False)
    # segment.inputs.tissues = [tissue1, tissue2, tissue3, tissue4, tissue5, tissue6]
    # segment.inputs.warping_regularization = [0, 0.001, 0.5, 0.05, 0.2]
    # segment.inputs.affine_regularization = 'mni'
    # segment.inputs.sampling_distance = 3
    ## ---

    normalize_func = pe.Node(interface=spm.Normalize12(), name="Normalise_Write_Functional")
    normalize_func.inputs.jobtype = 'write'
    normalize_func.inputs.write_voxel_sizes = [3, 3, 3]
    ## Default values :
    ## ---
    # normalize.inputs.write_bounding_box = [[-78, -112, -70], [78, 76, 85]]
    # normalize.inputs.write_interp = 4
    # normalize.inputs.out_prefix = 'w'
    ## ---

    normalize_anat = pe.Node(interface=spm.Normalize12(), name="Normalise_Write_Anatomical")
    normalize_anat.inputs.jobtype = 'write'
    normalize_anat.inputs.write_voxel_sizes = [1, 1, 1]
    ## Default values :
    ## ---
    # normalize.inputs.write_bounding_box = [[-78, -112, -70], [78, 76, 85]]
    # normalize.inputs.write_interp = 4
    # normalize.inputs.out_prefix = 'w'
    ## ---

    smooth = pe.Node(interface=spm.Smooth(), name="Smooth")
    ## Default values :
    ## ---
    # smooth.inputs.data_type = 0
    # smooth.inputs.implicit_masking = 0
    # smooth.inputs.out_prefix = 's'
    ## ---

    inputs = get_input()

    preproc.connect([
        (inputs, realign, [('func', 'in_files')]),
        (realign, sliceTiming, [('realigned_files', 'in_files')]),
        (realign, coregister, [('mean_image', 'target')]),
        (inputs, coregister, [('anat', 'source')]),
        (coregister, segment, [('coregistered_source', 'channel_files')]),
        (segment, normalize_anat, [('bias_corrected_images', 'apply_to_files')]),
        (segment, normalize_anat, [('forward_deformation_field', 'deformation_file')]),
        (sliceTiming, normalize_func, [('timecorrected_files', 'apply_to_files')]),
        (segment, normalize_func, [('forward_deformation_field', 'deformation_file')]),
        (normalize_func, smooth, [('normalized_files', 'in_files')]),
    ])

    return preproc


def get_subject_analysis_categorical():
    analysis = pe.Workflow(name='1st_Level_Analysis_Categorical')

    # set matlab path into SPM
    # See https://github.com/miykael/nipype_tutorial/issues/141
    spm.SPMCommand.set_mlab_paths(matlab_cmd=matlab_path)

    modelspec = pe.Node(interface=model.SpecifySPMModel(), name="Specify_1st_level_Categorical")
    modelspec.inputs.input_units = units
    modelspec.inputs.output_units = units
    modelspec.inputs.time_repetition = tr
    modelspec.inputs.high_pass_filter_cutoff = 128
    modelspec.inputs.subject_info = get_categorical_conditions()

    level1design = pe.Node(interface=spm.Level1Design(), name="level1design_Categorical")
    level1design.inputs.timing_units = units
    level1design.inputs.interscan_interval = tr
    level1design.inputs.bases = {'hrf': {'derivs': [1, 1]}}
    level1design.inputs.model_serial_correlations = 'AR(1)'
    level1design.inputs.mask_threshold = 0.8
    level1design.inputs.volterra_expansion_order = 1
    level1design.inputs.microtime_onset = slices_nb / 2
    level1design.inputs.microtime_resolution = slices_nb
    #level1design.inputs.factor_info = [dict(name='Fame', levels=2), dict(name='Rep', levels=2)]
    # level1design.inputs.global_intensity_normalization = 'none'
    # level1design.inputs.flags = {'mthresh': 0.8}

    estimate = pe.Node(interface=spm.EstimateModel(), name="Model_Estimation_Categorical")
    estimate.inputs.estimation_method = {'Classical': 1}
    estimate.inputs.write_residuals = True

    contrast = pe.Node(interface=spm.EstimateContrast(), name="Contrast_manager")
    contrast.inputs.contrasts = get_parametric_contrasts()
    contrast.inputs.use_derivs = True

    analysis.connect([
        (modelspec, level1design, [('session_info', 'session_info')]),
        (level1design, estimate, [('spm_mat_file', 'spm_mat_file')]),
        (estimate, contrast,
         [('spm_mat_file', 'spm_mat_file'), ('beta_images', 'beta_images'), ('residual_image', 'residual_image')])
    ])

    return analysis


def get_subject_analysis_parametric():
    analysis = pe.Workflow(name='1st_Level_Analysis_Parametric')

    # set matlab path into SPM
    # See https://github.com/miykael/nipype_tutorial/issues/141
    spm.SPMCommand.set_mlab_paths(matlab_cmd=matlab_path)

    modelspec = pe.Node(interface=model.SpecifySPMModel(), name="Specify_1st_level_Parametric")
    modelspec.inputs.input_units = units
    modelspec.inputs.output_units = units
    modelspec.inputs.time_repetition = tr
    modelspec.inputs.high_pass_filter_cutoff = 128
    modelspec.inputs.subject_info = get_categorical_conditions()

    level1design = pe.Node(interface=spm.Level1Design(), name="level1design_Parametric")
    level1design.inputs.timing_units = units
    level1design.inputs.interscan_interval = tr
    level1design.inputs.bases = {'hrf': {'derivs': [0, 0]}}
    level1design.inputs.model_serial_correlations = 'AR(1)'
    level1design.inputs.mask_threshold = 0.8
    level1design.inputs.volterra_expansion_order = 1
    level1design.inputs.microtime_onset = slices_nb / 2
    level1design.inputs.microtime_resolution = slices_nb
    # level1design.inputs.global_intensity_normalization = 'none'
    # level1design.inputs.flags = {'mthresh': 0.8}

    estimate = pe.Node(interface=spm.EstimateModel(), name="Model_Estimation_Parametric")
    estimate.inputs.estimation_method = {'Classical': 1}
    estimate.inputs.write_residuals = True

    contrast = pe.Node(interface=spm.EstimateContrast(), name="Contrast_manager")
    contrast.inputs.contrasts = get_parametric_contrasts()
    contrast.inputs.use_derivs = True

    analysis.connect([
        (modelspec, level1design, [('session_info', 'session_info')]),
        (level1design, estimate, [('spm_mat_file', 'spm_mat_file')]),
        (estimate, contrast,
         [('spm_mat_file', 'spm_mat_file'), ('beta_images', 'beta_images'), ('residual_image', 'residual_image')])
    ])

    return analysis


def get_subject_analysis_bayesian():
    analysis = pe.Workflow(name='1st_Level_Analysis_Bayesian')

    # set matlab path into SPM
    # See https://github.com/miykael/nipype_tutorial/issues/141
    spm.SPMCommand.set_mlab_paths(matlab_cmd=matlab_path)

    modelspec = pe.Node(interface=model.SpecifySPMModel(), name="Specify_1st_level_Bayesian")
    modelspec.inputs.input_units = units
    modelspec.inputs.output_units = units
    modelspec.inputs.time_repetition = tr
    modelspec.inputs.high_pass_filter_cutoff = 128
    modelspec.inputs.subject_info = get_categorical_conditions()

    level1design = pe.Node(interface=spm.Level1Design(), name="level1design_Bayesian")
    level1design.inputs.timing_units = units
    level1design.inputs.interscan_interval = tr
    level1design.inputs.bases = {'hrf': {'derivs': [1, 1]}}
    level1design.inputs.model_serial_correlations = 'AR(1)'
    level1design.inputs.mask_threshold = 0.8
    level1design.inputs.volterra_expansion_order = 1
    level1design.inputs.microtime_onset = slices_nb / 2
    level1design.inputs.microtime_resolution = slices_nb
    # level1design.inputs.global_intensity_normalization = 'none'
    # level1design.inputs.flags = {'mthresh': 0.8}

    estimate = pe.Node(interface=spm.EstimateModel(), name="Model_Estimation_Bayesian")
    estimate.inputs.estimation_method = {'Bayesian2': 1}
    estimate.inputs.write_residuals = True

    contrast = pe.Node(interface=spm.EstimateContrast(), name="Contrast_manager")

    analysis.connect([
        (modelspec, level1design, [('session_info', 'session_info')]),
        (level1design, estimate, [('spm_mat_file', 'spm_mat_file')]),
        (estimate, contrast,
         [('spm_mat_file', 'spm_mat_file'), ('beta_images', 'beta_images'), ('residual_image', 'residual_image')])
    ])
    contrast.inputs.contrasts = get_bayesian_contrasts()
    contrast.inputs.use_derivs = True

    return analysis


def compare_outputs():
    orig_func_path = '/home/ymerel/fmri_pipeline_playground/spm/face/matlab/data/RawEPI/'
    orig_anat_path = '/home/ymerel/fmri_pipeline_playground/spm/face/matlab/data/Structural/'
    orig_results_path = '/home/ymerel/fmri_pipeline_playground/spm/face/matlab/results/'

    # COMPARE PREPROCESSING STEPS

    realigned_name = 'rsub-01_task-auditory_bold.nii'

    # print_correlation("REALIGNED",
    #                    orig_func_path + realigned_name,
    #                    work_dir + '/Preprocessing/_subject_id_01/Realign_Estimate_Reslice/' + realigned_name)

    mean_name = 'meansM03953_0005_0006.img'
    print_correlation("MEAN",
                      orig_func_path + mean_name,
                      work_dir + '/Preprocessing/Realign_Estimate_Reslice/' + mean_name)

    segmented_name = 'y_sM03953_0007.nii'
    print_correlation("SEGMENTED",
                      orig_anat_path + segmented_name,
                      work_dir + '/Preprocessing/Segment/' + segmented_name)

    coregister_name = 'sM03953_0007.img'
    print_correlation("COREGISTER ESTIMATE",
                      orig_anat_path + coregister_name,
                      work_dir + '/Preprocessing/Coregister_Estimate/' + coregister_name)

    # timecorrected_name = 'arsub-01_task-auditory_bold.nii'
    # print_correlation("TIME CORRECTED",
    #                    orig_func_path + timecorrected_name,
    #                    work_dir + '/Preprocessing/_subject_id_01/Slice_Timing/' + timecorrected_name)

    # normalised_name = 'warsub-01_task-auditory_bold.nii'
    # print_correlation("NORMALISE WRITE",
    #                    orig_func_path + normalised_name,
    #                    work_dir + '/Preprocessing/_subject_id_01/Normalise_Write/' + normalised_name)
    #
    # smoothed_name = 'swarsub-01_task-auditory_bold.nii'
    # print_correlation("SMOOTHED",
    #                    orig_func_path + smoothed_name,
    #                    work_dir + '/Preprocessing/_subject_id_01/Smooth/' + smoothed_name)

    # COMPARE 1ST LEVEL STEPS

    # con1_name = 'con_0001.nii'
    # con2_name = 'con_0002.nii'
    #
    # print_correlation("CONTRAST 1",
    #                    orig_results_path + con1_name,
    #                    work_dir + '/Preprocessing_1st_Level_Analysis/1st_Level_Analysis/_subject_id_01/Contrast_manager/' + con1_name)
    #
    # print_correlation("CONTRAST 2",
    #                    orig_results_path + con2_name,
    #                    work_dir + '/Preprocessing_1st_Level_Analysis/1st_Level_Analysis/_subject_id_01/Contrast_manager/' + con2_name)
    #
    # map1_name = 'spmT_0001.nii'
    # map2_name = 'spmT_0002.nii'
    #
    # print_correlation("MAP 1",
    #                    orig_results_path + map1_name,
    #                    work_dir + '/Preprocessing_1st_Level_Analysis/1st_Level_Analysis/_subject_id_01/Contrast_manager/' + map1_name)
    #
    # print_correlation("MAP 2",
    #                    orig_results_path + map2_name,
    #                    work_dir + '/Preprocessing_1st_Level_Analysis/1st_Level_Analysis/_subject_id_01/Contrast_manager/' + map2_name)


if __name__ == '__main__':
    get_pipeline().run()
    compare_outputs()
