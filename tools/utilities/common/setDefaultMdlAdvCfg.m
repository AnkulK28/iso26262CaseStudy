function setDefaultMdlAdvCfg()
%setDefaultMdlAdvCfg Set the default Model Advisor Configuration.
%    
% Note - Changing the default configuration will persist between Simulink
% sessions.
%

%   Copyright 2021 The MathWorks, Inc.

if iec.internal.license('test', 'Simulink Check')
    configFile = advisorConfigurationControl('set',ProjArtifacts.maUnitChecksJson);
    disp('*************************************************')
    disp('Set the Default Model Advisor Configuration to:')
    disp(configFile);
    disp('*************************************************')
end
