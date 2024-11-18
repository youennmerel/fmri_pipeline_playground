import hashlib
import os
from builtins import range

import nipype.algorithms.modelgen as model  # model specification
import nipype.interfaces.matlab as mlab  # how to run matlab
import nipype.interfaces.spm as spm  # spm
import nipype.pipeline.engine as pe  # pypeline engine
from nipype import IdentityInterface, SelectFiles, DataSink

matlab_path = '/home/ymerel/matlab/bin/matlab'
matlab_cmd = matlab_path + " -nodesktop -nosplash"
spm_path = '/home/ymerel/spm12/'


# Matlab command line
mlab.MatlabCommand.set_default_matlab_cmd(matlab_cmd)
# set SPM path into matlab
mlab.MatlabCommand.set_default_paths(os.path.abspath(spm_path))

# http://www.fil.ion.ucl.ac.uk/spm/data/auditory/
data_dir = os.path.abspath('/home/ymerel/fmri_pipeline_playground/spm/auditory/nipype/data')
results_dir = os.path.abspath('/home/ymerel/fmri_pipeline_playground/spm/auditory/nipype/results')
work_dir = os.path.abspath('/home/ymerel/fmri_pipeline_playground/spm/auditory/nipype/work')
events_file = '/home/ymerel/fmri_pipeline_playground/spm/auditory/nipype/auditory_events.tsv'
subjects = ['01']

slices_nb = 64
tr = 7.0
units = 'scans'


def get_infos():
    infos = pe.Node(IdentityInterface(fields=['subject_id']), name="infos")
    infos.iterables = [('subject_id', subjects)]
    return infos


def get_input():
    templates = {'anat': os.path.join(data_dir, 'sub-{subject_id}', 'anat', 'sub-{subject_id}_T1w.nii'),
                 'func': os.path.join(data_dir, 'sub-{subject_id}', 'func', 'sub-{subject_id}_task-auditory_bold.nii'),
                 'events': events_file }
    return pe.Node(SelectFiles(templates, base_directory=data_dir), name="input")


def get_output():
    return pe.Node(DataSink(base_directory=results_dir), name="output")


def get_pipeline():
    preproc = get_preprocessing()
    analysis = get_subject_analysis()

    pipeline = pe.Workflow(name='Preprocessing_1st_Level_Analysis')
    pipeline.base_dir = work_dir
    pipeline.connect([(preproc, analysis,
                       [
                        ('input.events', 'Specify_1st_level.bids_event_file'),
                        ('Realign_Estimate_Reslice.realignment_parameters', 'Specify_1st_level.realignment_parameters'),
                        ('Smooth.smoothed_files', 'Specify_1st_level.functional_runs')]
                       )])

    return pipeline


def get_preprocessing():
    # Preprocessing
    preproc = pe.Workflow(name='Preprocessing')

    realign = pe.Node(interface=spm.Realign(), name="Realign_Estimate_Reslice")
    realign.inputs.jobtype = 'estwrite'
    realign.inputs.quality = 0.9
    realign.inputs.separation = 4
    realign.inputs.fwhm = 5
    realign.inputs.register_to_mean = True
    realign.inputs.interp = 2
    realign.inputs.wrap = [0, 0, 0]
    # realign.inputs.weight_img = None
    realign.inputs.write_which = [2, 1]
    realign.inputs.write_interp = 4
    realign.inputs.write_wrap = [0, 0, 0]
    realign.inputs.write_mask = True

    sliceTiming = pe.Node(interface=spm.SliceTiming(), name="Slice_Timing")
    sliceTiming.inputs.num_slices = slices_nb
    sliceTiming.inputs.time_repetition = tr
    sliceTiming.inputs.time_acquisition = tr - (tr / slices_nb)
    sliceTiming.inputs.slice_order = list(range(slices_nb, 0, -1))  # [64 63 62 ... 3 2 1]
    sliceTiming.inputs.ref_slice = slices_nb / 2

    coregister = pe.Node(interface=spm.Coregister(), name="Coregister_Estimate")
    coregister.inputs.jobtype = 'estimate'
    # coregister.inputs.apply_to_files = None
    # coregister.inputs.cost_function = 'nmi'
    # coregister.inputs.separation = [4.0, 2.0]
    # coregister.inputs.tolerance = [0.02, 0.02, 0.02, 0.001, 0.001, 0.001, 0.01, 0.01, 0.01, 0.001, 0.001, 0.001]
    # coregister.inputs.fwhm = [7.0, 7.0]

    segment = pe.Node(interface=spm.NewSegment(), name="Segment")
    # channel.biasreg, channel.biasfwhm, channel.write (Field, Corrected)
    segment.inputs.channel_info = (0.001, 60.0, (False, True))
    tpm_file = os.path.abspath(os.path.join(spm_path, 'tpm/TPM.nii'))
    tissue1 = (tpm_file, 1), 1, (True, False), (False, False)
    tissue2 = (tpm_file, 2), 1, (True, False), (False, False)
    tissue3 = (tpm_file, 3), 2, (True, False), (False, False)
    tissue4 = (tpm_file, 4), 3, (True, False), (False, False)
    tissue5 = (tpm_file, 5), 4, (True, False), (False, False)
    tissue6 = (tpm_file, 6), 2, (False, False), (False, False)
    segment.inputs.tissues = [tissue1, tissue2, tissue3, tissue4, tissue5, tissue6]
    # matlabbatch{4}.spm.spatial.preproc.warp.mrf = 1;
    # matlabbatch{4}.spm.spatial.preproc.warp.cleanup = 1;
    segment.inputs.warping_regularization = [0, 0.001, 0.5, 0.05, 0.2]
    segment.inputs.affine_regularization = 'mni'
    # matlabbatch{4}.spm.spatial.preproc.warp.fwhm = 0;
    segment.inputs.sampling_distance = 3
    segment.inputs.write_deformation_fields = [False, True]
    # matlabbatch{4}.spm.spatial.preproc.warp.vox = NaN;
    # matlabbatch{4}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
    #                                    NaN NaN NaN];

    normalize = pe.Node(interface=spm.Normalize12(), name="Normalise_Write")
    normalize.inputs.jobtype = 'write'
    # normalize.inputs.write_bounding_box = [[-78, -112, -70], [78, 76, 85]]
    # normalize.inputs.write_voxel_sizes = [3, 3, 3]
    # normalize.inputs.write_interp = 4
    # normalize.inputs.out_prefix = 'w'

    smooth = pe.Node(interface=spm.Smooth(), name="Smooth")
    # smooth.inputs.data_type = 0
    # smooth.inputs.implicit_masking = 0
    # smooth.inputs.out_prefix = 's'

    infos = get_infos()
    inputs = get_input()

    preproc.connect([
        (infos, inputs, [('subject_id', 'subject_id')]),
        (inputs, realign, [('func', 'in_files')]),
        (realign, sliceTiming, [('realigned_files', 'in_files')]),
        (realign, coregister, [('mean_image', 'target')]),
        (inputs, coregister, [('anat', 'source')]),
        (coregister, segment, [('coregistered_source', 'channel_files')]),
        (sliceTiming, normalize, [('timecorrected_files', 'apply_to_files')]),
        (segment, normalize, [('forward_deformation_field', 'deformation_file')]),
        (normalize, smooth, [('normalized_files', 'in_files')]),
    ])

    return preproc


def get_subject_analysis():
    # 1st Level Analysis

    analysis = pe.Workflow(name='1st_Level_Analysis')

    # set matlab path into SPM
    # See https://github.com/miykael/nipype_tutorial/issues/141
    spm.SPMCommand.set_mlab_paths(matlab_cmd=matlab_path)

    modelspec = pe.Node(interface=model.SpecifySPMModel(), name="Specify_1st_level")
    modelspec.inputs.input_units = units
    modelspec.inputs.time_repetition = tr
    modelspec.inputs.high_pass_filter_cutoff = 128

    level1design = pe.Node(interface=spm.Level1Design(), name="level1design")
    level1design.inputs.timing_units = units
    level1design.inputs.interscan_interval = tr
    level1design.inputs.bases = {'hrf': {'derivs': [0, 0]}}
    level1design.inputs.model_serial_correlations = 'AR(1)'
    level1design.inputs.mask_threshold = 0.8
    level1design.inputs.volterra_expansion_order = 1

    estimate = pe.Node(interface=spm.EstimateModel(), name="Model_Estimation")
    estimate.inputs.estimation_method = {'Classical': 1}
    estimate.inputs.write_residuals = True

    contrast = pe.Node(interface=spm.EstimateContrast(), name="Contrast_manager")
    contrast.inputs.contrasts = [
        ('listening > rest', 'T', ['listening'], [1]),
        ('rest > listening', 'T', ['listening'], [-1])
    ]


    analysis.connect([
        (modelspec, level1design, [('session_info', 'session_info')]),
        (level1design, estimate, [('spm_mat_file', 'spm_mat_file')]),
        (estimate, contrast,
         [('spm_mat_file', 'spm_mat_file'), ('beta_images', 'beta_images'), ('residual_image', 'residual_image')]),
    ])

    return analysis


def compare_outputs():
    orig_func_path = '/home/ymerel/fmri_pipeline_playground/spm/auditory/matlab/data/sub-01/func/'
    orig_anat_path = '/home/ymerel/fmri_pipeline_playground/spm/auditory/matlab/data/sub-01/anat/'
    orig_results_path = '/home/ymerel/fmri_pipeline_playground/spm/auditory/matlab/results/'

    # COMPARE PREPROCESSING STEPS

    realigned_name = 'rsub-01_task-auditory_bold.nii'

    print_file_compare("REALIGNED",
                       orig_func_path + realigned_name,
                       work_dir + '/Preprocessing/_subject_id_01/Realign_Estimate_Reslice/' + realigned_name)

    mean_name = 'meansub-01_task-auditory_bold.nii'
    print_file_compare("MEAN",
                       orig_func_path + mean_name,
                       work_dir + '/Preprocessing/_subject_id_01/Realign_Estimate_Reslice/' + mean_name)

    segmented_name = 'y_sub-01_T1w.nii'
    print_file_compare("SEGMENTED",
                       orig_anat_path + segmented_name,
                       work_dir + '/Preprocessing/_subject_id_01/Segment/' + segmented_name)

    coregister_name = 'sub-01_T1w.nii'
    print_file_compare("COREGISTER ESTIMATE",
                       orig_anat_path + coregister_name,
                       work_dir + '/Preprocessing/_subject_id_01/Coregister_Estimate/' + coregister_name)

    timecorrected_name = 'arsub-01_task-auditory_bold.nii'
    print_file_compare("TIME CORRECTED",
                       orig_func_path + timecorrected_name,
                       work_dir + '/Preprocessing/_subject_id_01/Slice_Timing/' + timecorrected_name)

    normalised_name = 'warsub-01_task-auditory_bold.nii'
    print_file_compare("NORMALISE WRITE",
                       orig_func_path + normalised_name,
                       work_dir + '/Preprocessing/_subject_id_01/Normalise_Write/' + normalised_name)

    smoothed_name = 'swarsub-01_task-auditory_bold.nii'
    print_file_compare("SMOOTHED",
                       orig_func_path + smoothed_name,
                       work_dir + '/Preprocessing/_subject_id_01/Smooth/' + smoothed_name)

    smoothed_name = 'swarsub-01_task-auditory_bold.nii'
    print_file_compare("SMOOTHED",
                       orig_func_path + smoothed_name,
                       work_dir + '/Preprocessing/_subject_id_01/Smooth/' + smoothed_name)

    # COMPARE 1ST LEVEL STEPS

    spm_mat = 'SPM.mat'

    print_file_compare("SPM.mat",
                       orig_results_path + spm_mat,
                       work_dir + '/Preprocessing_1st_Level_Analysis/1st_Level_Analysis/_subject_id_01/Contrast_manager/' + spm_mat)

    con1_name = 'con_0001.nii'
    con2_name = 'con_0002.nii'

    print_file_compare("CONTRAST 1",
                       orig_results_path + con1_name,
                       work_dir + '/Preprocessing_1st_Level_Analysis/1st_Level_Analysis/_subject_id_01/Contrast_manager/' + con1_name)

    print_file_compare("CONTRAST 2",
                       orig_results_path + con2_name,
                       work_dir + '/Preprocessing_1st_Level_Analysis/1st_Level_Analysis/_subject_id_01/Contrast_manager/' + con2_name)

    map1_name = 'spmT_0001.nii'
    map2_name = 'spmT_0002.nii'

    print_file_compare("MAP 1",
                       orig_results_path + map1_name,
                       work_dir + '/Preprocessing_1st_Level_Analysis/1st_Level_Analysis/_subject_id_01/Contrast_manager/' + map1_name)

    print_file_compare("MAP 2",
                       orig_results_path + map2_name,
                       work_dir + '/Preprocessing_1st_Level_Analysis/1st_Level_Analysis/_subject_id_01/Contrast_manager/' + map2_name)


def print_file_compare(step_name, path1, path2):
    path1_sum = get_file_md5(path1)
    path_2_sum = get_file_md5(path2)

    operator = " == "
    if path1_sum != path_2_sum:
        operator = " <> "

    print("Compare [" + step_name + "] : "
          + path1_sum
          + operator
          + path_2_sum)


def get_file_md5(path: str):
    with open(path, 'rb') as file:
        content = file.read()
        return hashlib.md5(content).hexdigest()


if __name__ == '__main__':
    get_pipeline().run()
    compare_outputs()
