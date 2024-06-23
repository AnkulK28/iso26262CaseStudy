function resetDefaultMdlAdvCfg()
%resetDefaultMdlAdvCfg Reset the default Model Advisor Configuration.
%    
% Note - Changing the default configuration will persist between Simulink
% sessions.
%

%   Copyright 2019 The MathWorks, Inc.

if iec.internal.license('test', 'Simulink Check')
    advisorConfigurationControl('reset');
    disp('*************************************************')
    disp('Restored the Default Model Advisor Configuration.')
    disp('*************************************************')
end
