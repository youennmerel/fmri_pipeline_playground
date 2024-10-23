from builtins import range

import nipype.interfaces.io as nio  # Data i/o
import nipype.interfaces.spm as spm  # spm
import nipype.interfaces.fsl as fsl  # fsl
import nipype.interfaces.matlab as mlab  # how to run matlab
import nipype.interfaces.fsl as fsl  # fsl
import nipype.interfaces.utility as util  # utility
import nipype.pipeline.engine as pe  # pypeline engine
import nipype.algorithms.modelgen as model  # model specification
import os

# Set the way matlab should be called
mlab.MatlabCommand.set_default_matlab_cmd("matlab -nodesktop -nosplash")

slices_nb = 64
tr = 7.0

# Preprocessing
preproc = pe.Workflow(name='Preprocessing')

realign = pe.Node(interface=spm.Realign(), name="Realign : Estimate & reslice")
realign.inputs.jobtype = 'estwrite'
realign.inputs.quality = 0.9
realign.inputs.separation = 4
realign.inputs.fwhm = 5
realign.inputs.register_to_mean = True
realign.inputs.interp = 2
realign.inputs.wrap = [0, 0, 0]
realign.inputs.weight_img = None
realign.inputs.write_which = [2, 1]
realign.inputs.write_interp = 4
realign.inputs.write_wrap = [0, 0, 0]
realign.inputs.write_mask = True

sliceTiming = pe.Node(interface=spm.SliceTiming(), name="Slice Timing")
sliceTiming.inputs.num_slices = slices_nb
sliceTiming.inputs.time_repetition = tr
sliceTiming.inputs.time_acquisition = tr - (tr / slices_nb)
sliceTiming.inputs.slice_order = list(range(slices_nb, 0, -1))  # [64 63 62 ... 3 2 1]
sliceTiming.inputs.ref_slice = slices_nb / 2

coregister = pe.Node(interface=spm.Coregister(), name="Coregister : estimate")
coregister.inputs.jobtype = 'estimate'
coregister.inputs.apply_to_files = None
coregister.inputs.cost_function = 'nmi'
coregister.inputs.separation = [4.0, 2.0]
coregister.inputs.tolerance = [0.02, 0.02, 0.02, 0.001, 0.001, 0.001, 0.01, 0.01, 0.01, 0.001, 0.001, 0.001]
coregister.inputs.fwhm = [7.0, 7.0]

segment = pe.Node(interface=spm.Segment(), name="Segment")
segment.inputs.bias_regularization = 0.001
segment.inputs.bias_fwhm = 60


normalize = pe.Node(interface=spm.Normalize12(), name="Normalise : Write")

smooth = pe.Node(interface=spm.Smooth(), name="Smooth")

# 1st Level Analysis

estimate = pe.Node(interface=spm.EstimateModel(), name="Model estimation")

contrast = pe.Node(interface=spm.EstimateModel(), name="Contrast manager")

results = pe.Node(interface=spm.(), name="Contrast manager")
