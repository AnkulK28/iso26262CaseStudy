function asil=validateASIL(inputStr)
%validateASIL Checks if inputStr is a valid ASIL level
%   Check if inputStr is a valid ASIL level and provide diagnostics if not
%   
%   ASIL=isvalidasil(InputStr)

%   Copyright 2021 The MathWorks, Inc.


errorMsg = ['Specified string for ASIL is either empty or not a valid ASIL. ', ...
        'Possible values for ASIL are QM|ASILA|ASILB|ASILC|ASILD'];
    
if nargin<1
    error(errorMsg);
end


possibleASILValues = {
    'QM'
    'ASILA'
    'ASILB'
    'ASILC'
    'ASILD'};

match = cellfun(@(asil)(strcmp(inputStr,asil)), possibleASILValues);
if any(match)
    asil = inputStr;
else
    error(errorMsg);
end

end