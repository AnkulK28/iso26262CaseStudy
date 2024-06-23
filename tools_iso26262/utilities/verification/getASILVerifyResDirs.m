function verifyResDirs=getASILVerifyResDirs()
%getASILVerifyResDirs get names for verification results subfolders
%   getASILVerifyMethods()

%   Copyright 2021 The MathWorks, Inc.


verifyResDirs = {
    'mMetrics'    %model_metrics
    'mReviews'    %model_reviews
    'mStdChks'    %model_standard_checks
    'mCovs'       %model_coverage
    'mDesErrs'    %design_error_detections
    'mil'         %mil_test_results
    'cStdChks'    %code_standard_checks
    'cCovs'       %code coverages
    'cspil'       %code SIL and PIL test results
    };
