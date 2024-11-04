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

        anatpreproc@{ shape: subprocess, label: "**Preprocessing of anatomical image**
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

    anatpreproc_note@{ shape: comment, label : "• Bias field correction
    • Brain extraction
    • Tissue segmentation"}

    fwhm_note@{ shape: comment, label : "= Full Width at Half Maximum
    The larger, the greater the smoothing
    "}

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
    "}


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

        inference_result@{ shape: docs, label: "**Inference results**
        Thresholded statistical maps
        "}

    end

    %% INFERENCE NOTES

    inf_threshold_note@{ shape: comment, label : "• 6-connectivity (faces)
    • 18-connectivity (faces+edges)
    • 26-connectivity (faces+edges+corners)
    "}


    distorsion_params@{ shape: rounded, label:  "fa:fa-gear field map and/or estimation ?
    " }
    
    motion_params@{ shape: rounded, label:  "fa:fa-gear use of ICA ?
    " }


    %% INPUTS
    func --> distorsion
    anat --> anatpreproc
    %% anat --> coregistration
    mni --> mni_version --> normalization
    field --> mapsmoothing

    %% PREPROCESSING
    %% field --> distorsion
    mapsmoothing --> distorsion
    distorsion --> timing
    timing --> timing_interpol --> motion
    distorsion <-- can be inverted --> motion
    motion --> target --> cost_func --> motion_interpol --> coregistration
    anatpreproc --> coregistration
    anatpreproc_note --o anatpreproc
    %% motion --> normalization
    coregistration --> normalization
    normalization --> normalization_method --> smoothing
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
    matrix --> param_modulation --> resp_time --> orthogonalization --> nuisance --> contrasts
    contrasts --> testing
    testing --> 1st_result

    %% GROUP LEVEL

    1st_result --> group_matrix
    group_matrix --> gls --> group_contrasts
    group_matrix --> ols --> group_contrasts
    group_contrasts --> group_testing
    group_testing --> group_result


    %% INFERENCE

    group_result --> threshold
    threshold --> inference --> roi
    roi --> voxel_wise --> inference_result
    roi --> cluster_wise
    cluster_wise --> inf_threshold --> inference_result
    inf_threshold_note --o inf_threshold

    distorsion_params --o distorsion
    motion_params --o motion
```
