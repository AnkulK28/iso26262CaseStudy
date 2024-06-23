function methods = getASILStructuralCoverage(asil)
%getASILStructuralCoverage get structural coverage methods
%   get structural coverage methods highly recommended by ISO 26262 for a
%   specific ASIL.
%   ASIL can be either 'QM'|'ASILA'|'ASILB'|'ASILC'|'ASILD'.
%
%   getASILStructuralCoverage(ASIL)

%   Copyright 2021 The MathWorks, Inc.

asil = validateASIL(asil);


switch asil
    case {'QM','ASILA'}
        methods = {'Statement_coverage'};
    case {'ASILB', 'ASILC'}
        methods = {'Statement_coverage' ;'Branch_coverage'};
    case 'ASILD'
        methods = {'Statement_coverage'; 'Branch_coverage'; 'MCDC_coverage'};
end


