function genSrcCode(modelName, varargin)
%genSrcCode Generate source code from model
%   Generate source code from the model.
%
%   genSrcCode(ModelName) generate code from the model as a reference model
%   genSrcCode(ModelName, 'TreatAsTopMdl') generate code from the model as
%       a top model

%   Copyright 2021-2022 The MathWorks, Inc.

if ~iec.internal.license('test','Embedded Coder')
    MSLDiagnostic('certqualkit:engine:ECMissLicense').reportAsError;
end

% Close all models.
if iec.internal.license('test', 'Simulink')
    bdclose('all');
end

% Check for prerequisites.
if ~exist(['open_', modelName], 'file')
    error(['Model startup script ''open_', modelName, ''' not found.']);
end

% Open the model.
disp(['Opening Simulink model ', modelName, '.']);
evalin('base', ['open_', modelName]);

% Generate code.
if nargin > 1
    slbuild(modelName);
else
    slbuild(modelName, 'ModelReferenceRTWTargetOnly');
end

% Close the model.
disp(['Closing Simulink model ', modelName, '.']);
close_system(modelName, 0);

end
