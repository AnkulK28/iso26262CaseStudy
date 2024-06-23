function checksum = getModelChecksum(modelName, varargin)
%getModelChecksum Get checksum of model
%   Return checksum of the model.
%
%   getModelChecksum(ModelName)
%   getModelChecksum(ModelName, 'TreatAsTopMdl')

%   Copyright 2021-2021 The MathWorks, Inc.


load_system(modelName);
if nargin > 1
    checksum = iec.internal.getModelChecksum(modelName, true);
else
    checksum = iec.internal.getModelChecksum(modelName, false);
end

end
