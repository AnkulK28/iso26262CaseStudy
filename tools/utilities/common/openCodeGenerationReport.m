function openCodeGenerationReport( reportName )
%OPENCODEGENERATIONREPORT Open code generation report

%   Copyright 2023 The MathWorks, Inc.

if ~exist( ProjArtifacts.getImplPathHTML(reportName), 'file' )
    unzip( ProjArtifacts.unitCodeGenPath + ".zip", ...
        ProjArtifacts.unitCodeGenPath );
end
web(ProjArtifacts.getImplPathHTML(reportName),'-new');