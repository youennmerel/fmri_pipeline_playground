Flowchart of fMRI processing stream
===
``` mermaid
flowchart TB

    %% Step declaration

    %% INPUTS
    func@{ shape: docs, label: "**Functional images**
        "}

    anat@{ shape: doc, label: "**Anatomical images**
        "}

    mni@{ shape: doc, label: "**MNI template**
        "}

    field@{ shape: doc, label: "**Field map**
        "}

    %% PREPROCESSING
    subgraph Preprocessing
        direction TB

        distorsion@{ shape: process, label: "**Distorsion Correction**
        Correct dropout and distorsion due to scanner magnetic field inhomogeneity
        "}

        mapsmoothing@{ shape: subprocess, label: "**Field map smoothing**
        "}
        
        timing@{ shape: process, label: "**Slice timing correction**
        Correct differences in slices acquisition timing
        "}

        timing_interpol@{ shape: decision, label: "Interpolation
        method"}
        
        motion@{ shape: process, label: "**Motion correction (realignment)**
        Correct brain misalignment across time serie due to head or physiological motion
        "}

        target@{ shape: decision, label: "Target 
        image"}

        cost_func@{ shape: decision, label: "Cost 
        function"}

        motion_interpol@{ shape: decision, label: "Interpolation 
        method"}

        coregistration@{ shape: process, label: "**Co-registration**
        Align anatomical and functional images of each subjects
        "}

        normalization@{ shape: process, label: "**Spatial normalization**
        Align subjects images to a common template
        "}

        mni_version@{ shape: decision, label: "Template
        version"}

        normalization_method@{ shape: decision, label: "Normalization 
        method"}
        
        smoothing@{ shape: process, label: "**Spatial smoothing**
        Remove high frequency information to increase the signal/noise ratio (blurring)
        "}

        fwhm@{ shape: decision, label: "FWHM
        value"}

    end

    %% PREPROCESSING NOTES

    target_note@{ shape: comment, label: "•  Middle image 
        • Mean image
        • First image
    "}

    cost_func_note@{ shape: comment, label: "• Least square (SPM) 
        • Normalized correlation ratio (FSL)
        • ...
    "}

    motion_interpol_note@{ shape: comment, label: "• Linear
        • High-order (spline, sinc, FT...)
    "}

    mni_version_note@{ shape: comment, label : "• MNI305
    • MNI152 (linear, NLIN 6th gen, NLIN 2009[a,b]...)
    • ..."}

    normalization_method_note@{ shape: comment, label : "• Landmark-based
    • Volume-based registration (linear, non-linear)
    • Computational anatomy
    • Surface-based"}


    fwhm_note@{ shape: comment, label : "(Full Width at Half Maximum)
    The larger, the greater the smoothing
    "}

    %% ANAT PREPROCESSING
    subgraph Structural image preprocessing
        anat_bias@{ shape: process, label: "**Bias field correction**
        Correct differences in intensities across the image
        "}

        anat_extract@{ shape: process, label: "**Brain extraction**
        Extract brain from other tissues (skull, spinal chord...)
        "}

        anat_segment@{ shape: process, label: "**Tissue segmentation**
        Categorize the different tissues composing the brain (WM, GM, CSF)
        "}
    end

    %% 1ST LEVEL
    subgraph Single Subject Analysis 
        direction TB

        hrf_model@{ shape: process, label: "**Signal modelling**
        Hemodynamic response function (HRF) modelling
        "}

        hrf@{ shape: decision, label: "HRF
        model"}

        noise@{ shape: process, label: "**Noise modelling**
        Incorporate noise (e.g. LF drift) into the GLM
        "}

        HP_filter@{ shape: decision, label: "High-pass
        filtering"}

        prewhitening@{ shape: decision, label: "Prewhitening
        "}

        precoloring@{ shape: decision, label: "Precoloring"}

        matrix@{ shape: process, label: "**Design matrix building**
        Choice of GLM regressors
        "}

        param_modulation@{ shape: decision, label: "Parametric
        modulation"}

        resp_time@{ shape: decision, label: "Response
        time"}

        orthogonalization@{ shape: decision, label: "Orthogonalization"}

        nuisance@{ shape: decision, label: "Nuisance
        regressors"}

        contrasts@{ shape: process, label: "**Contrasts definition**
        Definition of hypothesis (H0, H1) and corresponding contrasts
        "}

        testing@{ shape: process, label: "**Statistical testing**
        "}

        1st_result@{ shape: docs, label: "**Analysis results**
        parameter estimates matrix
        3D statistical maps
        3D contrasts maps
        3D variance contrast maps
        "}

    end

    %% 1ST LEVEL NOTES

    hrf_note@{ shape: comment, label : "• Canonical HRF
    • With derivatives
    • Finite Impulse Response Model
    • Constrained Basis Sets
    "}

    HP_filter_note@{ shape: comment, label : "Filter out LF noise (drift)
    • Discrete Cosine Function
    • LOWESS (FSL)
    "}

    prewhitening_note@{ shape: comment, label : "Remove temporal autocorrelation between adjacent time points data
    "}

    precoloring_note@{ shape: comment, label : "Temporal smoothing to swamp the correlation
    "}

    param_modulation_note@{ shape: comment, label : "Model the variation in neural response strength
    linked to stimulus modulation
    "}

    resp_time_note@{ shape: comment, label : "Model differences in
    subject's response time
    "}

    orthogonalization_note@{ shape: comment, label: "Remove correlation
    between regressors"}

    nuisance_note@{ shape: comment, label: "• physiological noise (breathing, heartbeat)
    • motion estimates (from motion correction)
    • CSF signal
    • WM signal"}
    

    %% GROUP LEVEL
    subgraph Group Analysis
        direction TB

        group_matrix@{ shape: process, label: "**Design matrix building**
            Choice of mixed effect GLM regressors
        "}

        gls@{ shape: decision, label: "GLS model
        estimation"}

        ols@{ shape: decision, label: "OLS model
        estimation"}

        orthogonalization@{ shape: decision, label: "Orthogonalization"}

        group_contrasts@{ shape: process, label: "**Contrasts definition**
        "}

        group_testing@{ shape: process, label: "**Statistical testing**
        "}

        group_result@{ shape: docs, label: "**Group analysis results**
        
        "}
    
    end

    %% GROUP LEVEL NOTE
    gls_note@{ shape: comment, label: "(Generalized Least Squares)
    Down-weight subject with high within-subject variance
    "}

    ols_note@{ shape: comment, label:  "(Ordinary Least Squares)
    Within-subject variance is assumed identical for all subjects
    "}

    %% INFERENCE
    subgraph Statistical inference

        threshold@{ shape: process, label: "**Thresholds definition**
        "}

        inference@{ shape: process, label: "**Inference**
        Application of thresholds on statistical maps
        "}

        roi@{ shape: decision, label: "ROI
        masks"}

        voxel_wise@{ shape: decision, label: "Voxel-wise"}

        cluster_wise@{ shape: decision, label: "Cluster-wise"}

        inf_threshold@{ shape: decision, label: "Threshold"}

        fwer@{ shape: decision, label: "FWER
        correction"}

        inference_result@{ shape: docs, label: "**Inference results**
        Thresholded statistical maps
        "}

    end

    %% INFERENCE NOTES

    roi_note@{ shape: comment, label: "Define Regions Of Interests on which to focus inference.
    Reduce the volume searched for activation (small volume correction)"}

    }

    voxel_wise_note@{ shape: comment, label: "Each voxel is tested individually"}

    cluster_wise_note@{ shape: comment, label: "Connected clusters of activated voxels are tested"}

    inf_threshold_note@{ shape: comment, label : "Define how voxels are connected into a cluster
    • 6-connectivity (faces)
    • 18-connectivity (faces+edges)
    • 26-connectivity (faces+edges+corners)
    "}

    fwer_note@{ shape: comment, label : "(Family Wise Error Rate)
        Correct P-value for multiple (voxel) testing 
        • Bonferroni correction
        • Random Field Theory
        • Monte Carlo simulation (AFNI)
        • Non parametric methods (bootstrap, permutation test [FSL, SPM])
        "}


    distorsion_params@{ shape: rounded, label:  "fa:fa-gear field map and/or estimation ?
    " }
    
    motion_params@{ shape: rounded, label:  "fa:fa-gear use of ICA ?
    " }


    %% INPUTS
    func --> distorsion
    anat --> anat_bias
    mni --> mni_version --> normalization
    mni_version_note --o mni_version
    field --> mapsmoothing

    %% PREPROCESSING
    %% field --> distorsion
    mapsmoothing --> distorsion
    distorsion --> timing
    timing --> timing_interpol --> motion
    distorsion <-- "can be inverted" --> motion
    motion --> target --> cost_func --> motion_interpol --> coregistration
    target_note --o target
    cost_func_note --o cost_func
    motion_interpol_note --o motion_interpol
    anat_bias --> anat_extract --> anat_segment --> coregistration
    %% motion --> normalization
    coregistration --> normalization
    normalization --> normalization_method --> smoothing
    normalization_method_note --o normalization_method
    smoothing --> fwhm
    fwhm --o fwhm_note

    %% 1ST LEVEL
    fwhm --> hrf_model
    hrf_model --> hrf
    hrf_note --o hrf
    hrf --> noise
    noise --> HP_filter
    HP_filter --> prewhitening --> matrix
    HP_filter --> precoloring --> matrix
    HP_filter_note --o HP_filter
    prewhitening_note --o prewhitening
    precoloring_note --o precoloring
    matrix --> param_modulation --> resp_time --> orthogonalization --> nuisance --> contrasts
    param_modulation_note --o param_modulation
    resp_time_note --o resp_time
    orthogonalization_note --o orthogonalization
    nuisance_note --o nuisance
    contrasts --> testing
    testing --> 1st_result

    %% GROUP LEVEL

    1st_result --> group_matrix
    group_matrix --> gls --> group_contrasts
    group_matrix --> ols --> group_contrasts
    ols_note --o ols
    gls_note --o gls
    group_contrasts --> group_testing
    group_testing --> group_result


    %% INFERENCE

    group_result --> threshold
    threshold --> inference --> roi
    roi --> voxel_wise --> fwer
    voxel_wise_note --o voxel_wise
    roi --> cluster_wise
    roi_note --o roi
    cluster_wise_note --o cluster_wise
    cluster_wise --> inf_threshold --> fwer
    inf_threshold_note --o inf_threshold
    fwer_note --o fwer
    fwer --> inference_result

    distorsion_params --o distorsion
    motion_params --o motion
```
