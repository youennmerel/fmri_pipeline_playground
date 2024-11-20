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
data_dir = os.path.abspath('/home/ymerel/fmri_pipeline_playground/spm/face/nipype/data')
results_dir = os.path.abspath('/home/ymerel/fmri_pipeline_playground/spm/face/results')
work_dir = os.path.abspath('/home/ymerel/fmri_pipeline_playground/spm/face/work')

slices_nb = 24
tr = 2
units = 'scans'

def get_input():
    templates = {'anat': os.path.join(data_dir, 'Structural', '*.img'),
                 'func': os.path.join(data_dir, 'RawEPI', '*.img')}
    return pe.Node(SelectFiles(templates, base_directory=data_dir), name="input")


def get_output():
    return pe.Node(DataSink(base_directory=results_dir), name="output")

def get_pipeline():
    preproc = get_preprocessing()
    analysis = get_subject_analysis()
    pipeline = preproc

    # pipeline = pe.Workflow(name='Preprocessing_1st_Level_Analysis')
    pipeline.base_dir = work_dir
    # pipeline.connect([(preproc, analysis,
    #                    [
    #                     ('Realign_Estimate_Reslice.realignment_parameters', 'Specify_1st_level.realignment_parameters'),
    #                     ('Smooth.smoothed_files', 'Specify_1st_level.functional_runs')]
    #                    )])

    return pipeline
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
    sliceTiming.inputs.time_acquisition = tr - (tr/slices_nb)
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

def get_subject_analysis():
    analysis = pe.Workflow(name='1st_Level_Analysis')
    return analysis


if __name__ == '__main__':
    get_pipeline().run()
