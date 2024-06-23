function methods = getASILVerifyMethods(asil)
%getASILVerifyMethods get verification methods 
%   get verification methods highly recommended by ISO 26262 for a
%   specific ASIL.
%   ASIL can be either 'QM'|'ASILA'|'ASILB'|'ASILC'|'ASILD'.
%
%   getASILVerifyMethods(ASIL)

%   Copyright 2021 The MathWorks, Inc.

asil = validateASIL(asil);
allMethods={
    'requirements_based_tests'
    'interface_tests'
    'fault_injection_tests'
    'resource_usage_tests'
    };

switch asil
    case 'QM'
        methods = allMethods([1]);
    case 'ASILA'
        methods = allMethods([1,2]);
    case 'ASILB'
        methods = allMethods([1,2]);
    case 'ASILC'
        methods = allMethods([1,2]);
    case 'ASILD'
        methods = allMethods;
end
        
        
        