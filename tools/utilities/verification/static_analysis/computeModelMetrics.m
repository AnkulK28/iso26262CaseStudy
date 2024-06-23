function computeModelMetrics(modelName, varargin)
%computeModelMetrics Compute metrics for model
%   Compute metrics for the model, and then generate the Model Advisor
%   report.
%
%   computeModelMetrics(ModelName)
%   computeModelMetrics(ModelName, 'TreatAsTopMdl')

%   Copyright 2021-2022 The MathWorks, Inc.

if ~iec.internal.license('test','Simulink Check')
    MSLDiagnostic('certqualkit:engine:SLCHKMissLicense').reportAsError;
end

% Close all models.
if iec.internal.license('test', 'Simulink')
    bdclose('all');
end

htmlFile = ProjArtifacts.getUnitModelMetricsHTML(modelName);
if exist(htmlFile, 'file')
    delete(htmlFile);
end

% Check for prerequisites.
if ~exist(['open_', modelName], 'file')
    error(['Model startup script ''open_', modelName, ''' not found.']);
end

% Open the model.
disp(['Opening Simulink model ', modelName, '.']);
evalin('base', ['open_', modelName]);

% Meaasure the model against enabled metrics in the Model Advisor configuration.
metricsJson = ProjArtifacts.metricsJson;
if nargin > 1
    ModelAdvisor.run(modelName, 'Configuration', metricsJson , ...
        'Force', 'on', 'TreatAsMdlRef', 'off');
else
    ModelAdvisor.run(modelName, 'Configuration', metricsJson, ...
        'Force', 'on', 'TreatAsMdlRef', 'on');
end

% Generate Model Advisor report
maH = Simulink.ModelAdvisor.getModelAdvisor(modelName);
if maH.reportExists(modelName)
    maH.exportReport(htmlFile);
end

% Open report
if exist(htmlFile,'file')
    open(htmlFile);
end

% Close the model.
disp(['Closing Simulink model ', modelName, '.']);
close_system(modelName, 0);

end
