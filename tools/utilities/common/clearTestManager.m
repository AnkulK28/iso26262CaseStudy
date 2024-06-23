function clearTestManager()
%clearTestManager Clear Test Manager
%   Clear all test files and result sets loaded in Test Manager.
%
%   clearTestManager()

%   Copyright 2021 The MathWorks, Inc.
if iec.internal.license('test', 'Simulink Test')
    sltest.testmanager.clear();
    sltest.testmanager.clearResults();
end
end
