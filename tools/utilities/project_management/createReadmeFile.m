function createReadmeFile(path,docName, optional)

if nargin<3
    optional=false;
end

readme_text = "Folder intentionally emtpy for demo. Placeholder for";
readme_optional_text = "Remove this folder if not applicable.";
fid = fopen(fullfile(path,'readme.txt'),'wt');
fprintf(fid, '%s %s.', readme_text,docName);
if optional
    fprintf(fid, '\n%s', readme_optional_text);
end
fclose(fid);