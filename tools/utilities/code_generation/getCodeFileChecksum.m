function checksum = getCodeFileChecksum(modelName, varargin)
%getCodeFileChecksum Get checksum of generated code files
%   Return checksum of the generated code files.
%
%   getCodeFileChecksum(ModelName)
%   getCodeFileChecksum(ModelName, 'TreatAsTopMdl')

%   Copyright 2021 The MathWorks, Inc.

if nargin > 1
    info = load(fullfile(Simulink.fileGenControl('get','CodeGenFolder'), [modelName, '_ert_rtw'], 'buildInfo.mat'));
else
    info = load(fullfile(Simulink.fileGenControl('get','CodeGenFolder'), 'slprj', 'ert', modelName, 'buildInfo.mat'));
end
srcFiles = info.buildInfo.Src.Files;
codeFiles = [];
checksum = [];
k = 0;
for i = 1:length(srcFiles)
    if isempty(regexp(srcFiles(i).FileName, '^ert_main.c', 'once'))
        tempFile = fullfile(srcFiles(i).Path, srcFiles(i).FileName);
        tempFile = strrep(tempFile, '$(START_DIR)', Simulink.fileGenControl('get','CodeGenFolder'));
        k = k + 1;
        codeFiles{k} = tempFile;
        checksum{k} = Simulink.getFileChecksum(codeFiles{k});
    end
end

end
