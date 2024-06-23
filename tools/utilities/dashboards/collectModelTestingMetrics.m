function collectModelTestingMetrics(varargin)
%collectModelTestingMetrics Collect model testing metrics
%   Trace artifacts, and then collect model testing metrics for all models
%   or the model if specified.
%
%   collectModelTestingMetrics()
%   collectModelTestingMetrics(ModelName)

%   Copyright 2021-2023 The MathWorks, Inc.

% Collect model testing metrics.
metricEngine = metric.Engine();
metricIDs = getAvailableMetricIds(metricEngine, App="DashboardApp", Dashboard="ModelUnitTesting");
if nargin > 0 && ~isempty(varargin{1})
    modelName = varargin{1};
    execute(metricEngine, metricIDs, 'ArtifactScope', {which(modelName), modelName});
else
    execute(metricEngine, metricIDs);
end

end
