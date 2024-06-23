classdef ISODemoTasks < JenkinsJob
    %ISODemoTasks Create a Jenkins build job for the ISO Project
    %   Create a Jenkins build job that exercises tasks of the ISO
    %   Project.
    
    %   Copyright 2021 The MathWorks, Inc.
    
    properties
        JobDir;      % Directory in which the build job is located.
        ReportDir;   % Directory in which reports for the build job are placed.
        ProjectDir;  % Directory in which the project is located.
        ProjectName; % Name of the project.
        Project;     % Handle to the Project.
        ModelNames;  % Names of models in the software units directory.
        CompModelNames; %Names of component models in the integration directory
        FullCoverage;  %Array hosting when software units achieve full structural coverage
    end
    
    properties
        
        TaskSequence = [
            "taskGenReqReport"
            "taskGenSDD"
            "taskCheckModelStds"
            "taskDetectDesignErrs"
            "taskVerifyModel2Reqs"
            "taskGenLowLevelTests"
            "taskVerifyModel2LowLevelTests"
            "taskMergeModelCoverage"
            "taskGenSrcCode"
            "taskCheckCodeStds"
            "taskVerifyObjCode2Reqs"
            "taskVerifyObjCode2LowLevelTests"
            "taskMergeCodeCoverage"
            "taskCheckCompModelStds"
            ];
    end
    
    methods
        
        function setupJob(this)
            % Equivalent to (TestClassSetup) of matlab.unittest.TestCase.
            this.JobDir = fileparts(mfilename('fullpath'));
            this.ReportDir = regexprep(this.JobDir, 'job$', 'reports');
            addpath(this.JobDir);
            this.clearCache();
            this.loadProject();
            this.getModelNames();
            this.getCompModelNames();
            this.FullCoverage = zeros(size(this.ModelNames));
            collectModelTestingMetrics();
        end
        
        function setupTask(this)
            % Equivalent to (TestMethodSetup) of matlab.unittest.TestCase.
        end
        
        function cleanupTask(this)
            % Equivalent to (TestMethodTeardown) of matlab.unittest.TestCase.
        end
        
        function cleanupJob(this)
            % Equivalent to (TestClassTeardown) of matlab.unittest.TestCase.
            collectModelTestingMetrics();
            metric.Engine().generateReport('Location', fullfile(ProjArtifacts.dashboardsPath,'ModelTestingDashboardStatus'), 'Type','html-file')
            metric.Engine().generateReport('Location', fullfile(ProjArtifacts.dashboardsPath,'ModelTestingDashboardStatus'), 'Type','pdf')
            this.closeProject();
            this.restoreDir();
        end
    end
    
    methods % For use by setupJob.
        function clearCache(this)
            % The MATLAB Compiler Runtime (MCR) cache can cause errors with
            % Polyspace in certain installations. Delete the entire cache
            % to avoid running into this problem.
            cacheDir = fullfile(tempdir, getenv('username'));
            if exist(cacheDir, 'dir')
                rmdir(cacheDir, 's');
            end
        end
        
        function loadProject(this)
            % Load the project.
            prj = dir(fullfile(this.JobDir, '..', '..', '*.prj'));
            this.ProjectDir = prj.folder;
            this.ProjectName = prj.name;
            this.Project = matlab.project.loadProject(fullfile(this.ProjectDir, this.ProjectName));
        end
        
        function getModelNames(this)
            % Return a list of models to be operated by each task in
            % TaskSequence.
            designDir = ProjArtifacts.unitDesignPath;
            dirList = dir(designDir);
            % Ignore names that are not a folder such as ".", ".."
            % Also ignore MPCController for demo purposes
            ignoreDir = arrayfun(@(x) (x.isdir == 0) || strcmpi(x.name, 'MPCController') || contains(x.name, '.'), dirList);
            dirList = dirList(~ignoreDir);
            this.ModelNames = arrayfun(@(x) (x.name), dirList, 'UniformOutput', false);
        end
        
        function getCompModelNames(this)
            % Return a list of composite component models.
            designDir = ProjArtifacts.compIntegrationPath;
            dirList = dir(designDir);
            % Ignore names that are not a folder such as ".", ".."
            ignoreDir = arrayfun(@(x) (x.isdir == 0) || contains(x.name, '.'), dirList);
            dirList = dirList(~ignoreDir);
            this.CompModelNames = arrayfun(@(x) (x.name), dirList, 'UniformOutput', false);
        end
    end
    
    methods % For use by setupTask.
    end
    
    methods % For use by cleanupTask.
    end
    
    methods % For use by cleanupJob.
        function closeProject(this)
            this.Project.close();
        end
        
        function restoreDir(this)
            cd(this.JobDir);
        end
    end
    
    methods % For use by assertion.
        function [newOutcome, newMsg, newCounter] = verifyOutcome(this, outcome, msg, lastMsg, lastOutcome, lastCounter)
            newOutcome = min(outcome, lastOutcome);
            if outcome == 1
                newCounter = lastCounter;
                newMsg = lastMsg;
            else
                % Append failure or warning to exception.
                newCounter = lastCounter + 1;
                if outcome == 0
                    tag = ['(', num2str(newCounter), ') WARNING: '];
                else
                    tag = ['(', num2str(newCounter), ') FAILURE: '];
                end
                if isempty(lastMsg)
                    newMsg = [tag, msg];
                else
                    newMsg = sprintf([lastMsg, '\n', tag, msg]);
                end
            end
        end
        
        function [newOutcome, newMsg, newCounter] = verifyFile(this, file, msg, lastMsg, lastOutcome, lastCounter)
            if exist(file, 'file')
                newOutcome = lastOutcome;
                newCounter = lastCounter;
                newMsg = lastMsg;
            else
                newOutcome = -1;
                % Append failure or warning to exception.
                newCounter = lastCounter + 1;
                tag = ['(', num2str(newCounter), ') FAILURE: '];
                if isempty(lastMsg)
                    newMsg = [tag, msg];
                else
                    newMsg = sprintf([lastMsg, '\n', tag, msg]);
                end
            end
        end
    end
    
    methods % For general use.
        function result = isTopModel(this, model)
            % Check if a model is a top-level model.
            % List all top-level models in the cell array below. Note that
            % a top-level model must not be referenced by another design
            % model. However, it may appear as a referenced model in a test
            % harness.
            allTopModels = {'HighwayLaneFollowingController'};
            result = any(strcmpi(allTopModels, model));
        end
        function result = isCompositeComponent(this, model)
            % Check if a model is a composite software component.
            dirList = dir(ProjArtifacts.compIntegrationPath);
            % Ignore common, sample_model, and names that are not a folder such as ".", "..", and ".svn".
            ignoreDir = arrayfun(@(x) (x.isdir == 0) || strcmpi(x.name, 'common') || contains(x.name, '.'), dirList);
            dirList = dirList(~ignoreDir);
            allSWCompModelNames = arrayfun(@(x) (x.name), dirList, 'UniformOutput', false);
            result = any(strcmpi(allSWCompModelNames, model));
        end
    end
    
    methods % Equivalent to (Test) of matlab.unittest.TestCase.
        function taskGenReqReport(this)
            % This test point checks if Requirements Reports generated from
            % requirement sets are successfully created by "genReqReport".
            
            fileExt = 'docx';
            outcome = 1;
            exception = '';
            counter = 0;
            try
                % Test generation of Requirements Reports from requirement
                % sets in the project.
                reqSets_system = dir(fullfile(ProjArtifacts.TSRS , '*.slreqx'));
                reqSets_software = dir(fullfile(ProjArtifacts.SSRS , '*.slreqx'));
                reqSets = [reqSets_system reqSets_software];
                for i = 1:numel(reqSets)
                    [~, reqSetName] = fileparts(reqSets(i).name);
                    genReqReport(reqSetName, [], 'CI');
                    file = fullfile(fileparts(which(reqSets(i).name)), [reqSetName, '_ReqReport.',fileExt]);
                    msg = ['Requirements Report not created for: ', reqSetName];
                    [outcome, exception, counter] = this.verifyFile(file, msg, exception, outcome, counter);
                end
                
                % Capture task execution outcome.
                this.TaskOutcomes('taskGenReqReport') = outcome;
                this.TaskExceptions('taskGenReqReport') = exception;
            catch ME
                % Throw exception if an error occurs.
                rethrow(ME);
            end
        end
        
        function taskGenSDD(this)
            % This test point checks if SDD Reports generated from models
            % are successfully created by "genSDD".
            
            outcome = 1;
            exception = '';
            counter = 0;
            try
                % Test generation of SDD Reports from models in the
                % project.
                for i = 1:numel(this.ModelNames)
                    modelName = this.ModelNames{i};
                    genSDD(modelName, [], 'CI');
                    file = fullfile(fileparts(which(modelName)), 'documents', [modelName, '_SDD.pdf']);
                    msg = ['SDD Report not created for: ', modelName];
                    [outcome, exception, counter] = this.verifyFile(file, msg, exception, outcome, counter);
                end
                
                % Capture task execution outcome.
                this.TaskOutcomes('taskGenSDD') = outcome;
                this.TaskExceptions('taskGenSDD') = exception;
            catch ME
                % Throw exception if an error occurs.
                rethrow(ME);
            end
        end
        
        function taskVerifyModel2Reqs(this)
            % This test point checks if Simulink Test and Model Coverage
            % Reports generated from models are successfully created by
            % "verifyModel2Reqs".
            
            outcome = 1;
            exception = '';
            counter = 0;
            try
                % Test generation of Simulink Test and Model Coverage
                % Reports (for HLR Simulation Tests) from models in the
                % project.
                title = 'MIL Simulation Tests';
                headers = {'Model Name', 'Num Pass', 'Num Warn', 'Num Fail', 'Outcome'};
                data = {};
                for i = 1:numel(this.ModelNames)
                    modelName = this.ModelNames{i};
                    if exist(ProjArtifacts.getUnitRBTTestFile(modelName), 'file') ...
                            && exist(ProjArtifacts.getRBTTestHarness(modelName), 'file')
                        if this.isTopModel(modelName)
                            res = verifyModel2Reqs(modelName, 'TreatAsTopMdl', [], 'CI');
                        else
                            res = verifyModel2Reqs(modelName, [], [], 'CI');
                        end
                        data(i,:) = {modelName, res.NumPass, res.NumWarn, res.NumFail, res.Outcome};
                        msg = ['One or more high-level simulation test cases failed on ', modelName, '.'];
                        [outcome, exception, counter] = this.verifyOutcome(res.Outcome, msg, exception, outcome, counter);
                        file = ProjArtifacts.getUnitMILResultsHLRPDF(modelName);
                        msg = ['Simulation Test Report not created for: ', modelName];
                        [outcome, exception, counter] = this.verifyFile(file, msg, exception, outcome, counter);
                        file = ProjArtifacts.getUnitMCovHLRHTML(modelName);
                        msg = ['Model Coverage Report not created: ', modelName];
                        [outcome, exception, counter] = this.verifyFile(file, msg, exception, outcome, counter);
                    else
                        data(i,:) = {modelName, [], [], [], []};
                    end
                end
                
                % Capture summary table data.
                this.TaskResults('taskVerifyModel2Reqs') = {title, headers, data};
                
                % Capture task execution outcome.
                this.TaskOutcomes('taskVerifyModel2Reqs') = outcome;
                this.TaskExceptions('taskVerifyModel2Reqs') = exception;
            catch ME
                % Throw exception if an error occurs.
                rethrow(ME);
            end
        end
        
        function taskCheckModelStds(this)
            % This test point checks if Model Advisor Reports generated
            % from models are successfully created by "checkModelStds".
            
           
            outcome = 1;
            exception = '';
            counter = 0;
            try
                % Test generation of Model Advisor Reports from models in
                % the project.
                title = 'Modeling Standards';
                headers = {'Model Name', 'Num Pass', 'Num Warn', 'Num Fail', 'Outcome'};
                data = {};
                for i = 1:numel(this.ModelNames)
                    modelName = this.ModelNames{i};
                    % Remove cache if it exists.
                    if exist(fullfile(this.ProjectDir, 'work', 'cache', 'slprj', 'modeladvisor', modelName), 'dir')
                        rmdir(fullfile(this.ProjectDir, 'work', 'cache', 'slprj', 'modeladvisor', modelName), 's');
                    end
                    if this.isTopModel(modelName)
                        res = checkModelStds(modelName, 'TreatAsTopMdl', 'CI');
                    else
                        res = checkModelStds(modelName, [], 'CI');
                    end
                    data(i,:) = {modelName, res.NumPass, res.NumWarn, res.NumFail, res.Outcome};
                    msg = ['One or more modeling standard violations found on ', modelName, '.'];
                    [outcome, exception, counter] = this.verifyOutcome(res.Outcome, msg, exception, outcome, counter);
                    file = ProjArtifacts.getUnitMStdChksHTML(modelName);
                    msg = ['Model Advisor Report not created for: ', modelName];
                    [outcome, exception, counter] = this.verifyFile(file, msg, exception, outcome, counter);
                end
                
                % Capture summary table data.
                this.TaskResults('taskCheckModelStds') = {title, headers, data};
                
                % Capture execution outcome.
                this.TaskOutcomes('taskCheckModelStds') = outcome;
                this.TaskExceptions('taskCheckModelStds') = exception;
            catch ME
                % Throw exception if an error occurs.
                rethrow(ME);
            end
        end
        
        function taskDetectDesignErrs(this)
            % This test point checks if Design Error Detection Reports
            % generated from models are successfully created by
            % "detectDesignErrs".
            
            outcome = 1;
            exception = '';
            counter = 0;
            try
                % Test generation of Design Error Detection Reports from
                % models in the project.
                title = 'Design Error Detection';
                headers = {'Model Name', 'Num Pass', 'Num Warn', 'Num Fail', 'Outcome'};
                data = {};
                for i = 1:numel(this.ModelNames)
                    modelName = this.ModelNames{i};
                    res = detectDesignErrs(modelName, [], [], 'CI');
                    data(i,:) = {modelName, res.NumPass, res.NumWarn, res.NumFail, res.Outcome};
                    msg = ['One or more design errors found on ', modelName, '.'];
                    [outcome, exception, counter] = this.verifyOutcome(res.Outcome, msg, exception, outcome, counter);
                    file = ProjArtifacts.getUnitDesErrsPDF(modelName);
                    msg = ['Design Error Detection Report not created for: ', modelName];
                    [outcome, exception, counter] = this.verifyFile(file, msg, exception, outcome, counter);
                end
                
                % Capture summary table data.
                this.TaskResults('taskDetectDesignErrs') = {title, headers, data};
                
                % Capture execution outcome.
                this.TaskOutcomes('taskDetectDesignErrs') = outcome;
                this.TaskExceptions('taskDetectDesignErrs') = exception;
            catch ME
                % Throw exception if an error occurs.
                rethrow(ME);
            end
        end
        
        function taskGenLowLevelTests(this)
            % This test point checks if Test Generation Reports generated
            % from models are successfully created by "genLowLevelTests".
            
            outcome = 1;
            exception = '';
            counter = 0;
            try
                % Test generation of Test Generation Reports from models in
                % the project.
                for i = 1:numel(this.ModelNames)
                    modelName = this.ModelNames{i};
                    if exist(ProjArtifacts.getUnitMCovHLRCvt(modelName), 'file')
                        fullCovAlreadyAcheived = genLowLevelTests(modelName, 'CI', true);
                        file = ProjArtifacts.getUnitSLDVTestGenReport(modelName);
                        msg = ['Test Generation Report not created for: ', modelName];
                        if ~fullCovAlreadyAcheived
                            [outcome, exception, counter] = this.verifyFile(file, msg, exception, outcome, counter);
                        else
                            this.FullCoverage(i) = 1;
                        end
                    end
                end
                
                % Capture execution outcome.
                this.TaskOutcomes('taskGenLowLevelTests') = outcome;
                this.TaskExceptions('taskGenLowLevelTests') = exception;
            catch ME
                % Throw exception if an error occurs.
                rethrow(ME);
            end
        end
        
        function taskVerifyModel2LowLevelTests(this)
            % This test point checks if Simulink Test and Code Coverage
            % Reports generated from models are successfully created by
            % "verifyModel2LowLevelTests".
            
            outcome = 1;
            exception = '';
            counter = 0;
            try
                % Test generation of Simulink Test and Code Coverage
                % Reports (for LLR EOC Tests) from models in the project.
                title = 'LLR MIL Tests';
                headers = {'Model Name', 'Num Pass', 'Num Warn', 'Num Fail', 'Outcome'};
                data = {};
                for i = 1:numel(this.ModelNames)
                    modelName = this.ModelNames{i};
                    if exist(ProjArtifacts.getUnitSLDVTestFile(modelName), 'file')
                        if this.isTopModel(modelName)
                            res = verifyModel2LowLevelTests(modelName, 'TreatAsTopMdl', [], 'CI');
                        else
                            res = verifyModel2LowLevelTests(modelName, [], [], 'CI');
                        end
                        data(i,:) = {modelName, res.NumPass, res.NumWarn, res.NumFail, res.Outcome};
                        msg = ['One or more low-level model-in-the-loop test cases failed on ', modelName, '.'];
                        [outcome, exception, counter] = this.verifyOutcome(res.Outcome, msg, exception, outcome, counter);
                        file = ProjArtifacts.getUnitMILResultsLLRPDF(modelName);
                        msg = ['Simulation Test Report not created for: ', modelName];
                        [outcome, exception, counter] = this.verifyFile(file, msg, exception, outcome, counter);
                        file = ProjArtifacts.getUnitMCovLLRHTML(modelName);
                        msg = ['Model Coverage Report not created for: ', modelName];
                        [outcome, exception, counter] = this.verifyFile(file, msg, exception, outcome, counter);
                    else
                        data(i,:) = {modelName, [], [], [], []};
                    end
                end
                
                % Capture summary table data.
                this.TaskResults('taskVerifyModel2LowLevelTests') = {title, headers, data};
                
                % Capture execution outcome.
                this.TaskOutcomes('taskVerifyModel2LowLevelTests') = outcome;
                this.TaskExceptions('taskVerifyModel2LowLevelTests') = exception;
            catch ME
                % Throw exception if an error occurs.
                rethrow(ME);
            end
        end
        
        function taskMergeModelCoverage(this)
            % This test point checks if Cumulative Code Coverage Reports
            % generated from models are successfully created by
            % "mergeCodeCoverage".
            
            outcome = 1;
            exception = '';
            counter = 0;
            try
                % Test generation of Cumulative Code Coverage Reports from
                % models in the project.
                title = 'Cumulative Model Coverage';
                headers = {'Model Name', 'Statement', 'Decision', 'Condition', 'MCDC', 'Outcome'};
                data = {};
                for i = 1:numel(this.ModelNames)
                    modelName = this.ModelNames{i};
                    if exist(ProjArtifacts.getUnitMILResultsHLRFile(modelName), 'file') ...
                            && exist(ProjArtifacts.getUnitMILResultsLLRFile(modelName), 'file')
                        disp(ProjArtifacts.getUnitMILResultsHLRFile(modelName));
                        disp(ProjArtifacts.getUnitMILResultsLLRFile(modelName));
                        res = mergeModelCoverage(modelName, 'CI');
                        if ~isempty(res) % empty results means tests either for LLR or HLR don't exist
                            data(i,:) = {modelName, res.CumulativeExecutionCov, res.CumulativeDecisionCov, res.CumulativeConditionCov, res.CumulativeMCDCCov, res.Outcome};
                            msg = ['One or more model coverage objectives not achieved on ', modelName, '.'];
                            [outcome, exception, counter] = this.verifyOutcome(res.Outcome, msg, exception, outcome, counter);
                            file = ProjArtifacts.getUnitMCovMRGHTML(modelName);
                            msg = ['Cumulative Model Coverage Report not created for: ', modelName];
                            [outcome, exception, counter] = this.verifyFile(file, msg, exception, outcome, counter);
                        else
                            data(i,:) = {modelName, [], [], [], [], []};
                        end
                    else
                        data(i,:) = {modelName, [], [], [], [], []};
                    end
                end
                
                % Capture summary table data.
                this.TaskResults('taskMergeModelCoverage') = {title, headers, data};
                
                % Capture execution outcome.
                this.TaskOutcomes('taskMergeModelCoverage') = outcome;
                this.TaskExceptions('taskMergeModelCoverage') = exception;
            catch ME
                % Throw exception if an error occurs.
                rethrow(ME);
            end
        end
        
        function taskGenSrcCode(this)
            % This test point checks if Code Generation Reports generated
            % from models are successfully created by "genSrcCode".
            
            outcome = 1;
            exception = '';
            counter = 0;
            try
                % Test generation of Code Generation Reports from models in
                % the project.
                for i = 1:numel(this.ModelNames)
                    modelName = this.ModelNames{i};
                    if this.isTopModel(modelName)
                        genSrcCode(modelName, 'TreatAsTopMdl');
                        file = ProjArtifacts.getImplPathHTML(modelName, true);
                    else
                        genSrcCode(modelName);
                        file = ProjArtifacts.getImplPathHTML(modelName, false);
                    end
                    msg = ['Code Generation Report not created for : ', modelName];
                    [outcome, exception, counter] = this.verifyFile(file, msg, exception, outcome, counter);
                end
                
                % Capture execution outcome.
                this.TaskOutcomes('taskGenSrcCode') = outcome;
                this.TaskExceptions('taskGenSrcCode') = exception;
            catch ME
                % Throw exception if an error occurs.
                rethrow(ME);
            end
        end
        
        function taskCheckCodeStds(this)
            % This test point checks if Bug Finder Reports generated from
            % models are successfully created by "checkCodeStds".
            
            outcome = 1;
            exception = '';
            counter = 0;
            try
                % Test generation of Bug Finder Reports from models in the
                % project.
                title = 'Coding Standards';
                headers = {'Model Name', 'Num MISRA violations', 'Outcome'};
                data = {};
                for i = 1:numel(this.ModelNames)
                    modelName = this.ModelNames{i};
                    if this.isTopModel(modelName)
                        res = checkCodeStds(modelName, 'TreatAsTopMdl', 'CI');
                    else
                        res = checkCodeStds(modelName, [], 'CI');
                    end
                    data(i,:) = {modelName, res.NumPurple, res.Outcome};
                    msg = ['One or more coding rule violations found on ', modelName, '.'];
                    [outcome, exception, counter] = this.verifyOutcome(res.Outcome, msg, exception, outcome, counter);
                    file = ProjArtifacts.getUnitCStdChksPDF(modelName);
                    msg = ['Bug Finder Report not created for: ', modelName];
                    [outcome, exception, counter] = this.verifyFile(file, msg, exception, outcome, counter);
                end
                
                % Capture summary table data.
                this.TaskResults('taskCheckCodeStds') = {title, headers, data};
                
                % Capture execution outcome.
                this.TaskOutcomes('taskCheckCodeStds') = outcome;
                this.TaskExceptions('taskCheckCodeStds') = exception;
            catch ME
                % Throw exception if an error occurs.
                rethrow(ME);
            end
        end
        
        function taskVerifyObjCode2Reqs(this)
            % This test point checks if Simulink Test and Code Coverage
            % Reports generated from models are successfully created by
            % "verifyObjCode2Reqs".
            
            outcome = 1;
            exception = '';
            counter = 0;
            mode = 'SIL';
            try
                % Test generation of Simulink Test and Code Coverage
                % Reports (for HLR EOC Tests) from models in the project.
                title = 'HLR SIL Tests';
                headers = {'Model Name', 'Num Pass', 'Num Warn', 'Num Fail', 'Outcome'};
                data = {};
                for i = 1:numel(this.ModelNames)
                    modelName = this.ModelNames{i};
                    if exist(ProjArtifacts.getUnitRBTTestFile(modelName), 'file')
                        if this.isTopModel(modelName)
                            res = verifyObjCode2Reqs(modelName, mode, [], 'TreatAsTopMdl', [], 'CI');
                        else
                            res = verifyObjCode2Reqs(modelName, mode, [], [], [], 'CI');
                        end
                        data(i,:) = {modelName, res.NumPass, res.NumWarn, res.NumFail, res.Outcome};
                        msg = ['One or more high-level software-in-the-loop test cases failed on ', modelName, '.'];
                        [outcome, exception, counter] = this.verifyOutcome(res.Outcome, msg, exception, outcome, counter);
                        file = ProjArtifacts.getUnitSPILRBTResPDF(modelName, mode, true);
                        msg = ['SIL Test Report not created for: ', modelName];
                        [outcome, exception, counter] = this.verifyFile(file, msg, exception, outcome, counter);
                        file = ProjArtifacts.getUnitRBTCCovHTML(modelName, mode);
                        msg = ['Code Coverage Report not created for : ', modelName];
                        [outcome, exception, counter] = this.verifyFile(file, msg, exception, outcome, counter);
                    else
                        data(i,:) = {modelName, [], [], [], []};
                    end
                end
                
                % Capture summary table data.
                this.TaskResults('taskVerifyObjCode2Reqs') = {title, headers, data};
                
                % Capture execution outcome.
                this.TaskOutcomes('taskVerifyObjCode2Reqs') = outcome;
                this.TaskExceptions('taskVerifyObjCode2Reqs') = exception;
            catch ME
                % Throw exception if an error occurs.
                rethrow(ME);
            end
        end
        
        function taskVerifyObjCode2LowLevelTests(this)
            % This test point checks if Simulink Test and Code Coverage
            % Reports generated from models are successfully created by
            % "verifyObjCode2LowLevelTests".
            
            outcome = 1;
            exception = '';
            counter = 0;
            try
                % Test generation of Simulink Test and Code Coverage
                % Reports (for LLR EOC Tests) from models in the project.
                title = 'LLR SIL Tests';
                headers = {'Model Name', 'Num Pass', 'Num Warn', 'Num Fail', 'Outcome'};
                data = {};
                mode = 'SIL';
                authors = 'MathWorks';
                for i = 1:numel(this.ModelNames)
                    modelName = this.ModelNames{i};
                    if exist(ProjArtifacts.getUnitSLDVTestFile(modelName), 'file')
                        if this.isTopModel(modelName)
                            res = verifyObjCode2LowLevelTests(modelName, mode, [], 'TreatAsTopMdl',authors ,'CI');
                        else
                            res = verifyObjCode2LowLevelTests(modelName, mode, [], [], authors ,'CI');
                        end
                        data(i,:) = {modelName, res.NumPass, res.NumWarn, res.NumFail, res.Outcome};
                        msg = ['One or more low-level software-in-the-loop test cases failed on ', modelName, '.'];
                        [outcome, exception, counter] = this.verifyOutcome(res.Outcome, msg, exception, outcome, counter);
                        file = ProjArtifacts.getUnitSPILLLRResPDF(modelName, mode, true);
                        msg = ['SIL Test Report not created for: ', modelName];
                        [outcome, exception, counter] = this.verifyFile(file, msg, exception, outcome, counter);
                        file = ProjArtifacts.getUnitLLRCCovHTML(modelName, mode);
                        msg = ['Code Coverage Report not created for: ', modelName];
                        [outcome, exception, counter] = this.verifyFile(file, msg, exception, outcome, counter);
                    else
                        data(i,:) = {modelName, [], [], [], []};
                    end
                end
                
                % Capture summary table data.
                this.TaskResults('taskVerifyObjCode2LowLevelTests') = {title, headers, data};
                
                % Capture execution outcome.
                this.TaskOutcomes('taskVerifyObjCode2LowLevelTests') = outcome;
                this.TaskExceptions('taskVerifyObjCode2LowLevelTests') = exception;
            catch ME
                % Throw exception if an error occurs.
                rethrow(ME);
            end
        end
        function taskMergeCodeCoverage(this)
            outcome = 1;
            exception = '';
            counter = 0;
            try
                % Test generation of Cumulative Code Coverage Reports from
                % models in the project.
                title = 'Cumulative Code Coverage';
                headers = {'Model Name', 'Statement', 'Decision', 'Condition', 'MCDC', 'Outcome'};
                data = {};
                mode = 'SIL';
                for i = 1:numel(this.ModelNames)
                    modelName = this.ModelNames{i};
                    if exist(ProjArtifacts.getUnitSPILRBTResFile(modelName, mode, true), 'file') ...
                            && exist(ProjArtifacts.getUnitSPILLLRResFile(modelName, mode, true), 'file')
                        res = mergeCodeCoverage(modelName, mode , 'CI');
                        data(i,:) = {modelName, res.CumulativeExecutionCov, res.CumulativeDecisionCov, res.CumulativeConditionCov, res.CumulativeMCDCCov, res.Outcome};
                        msg = ['One or more code coverage objectives not achieved on ', modelName, '.'];
                        [outcome, exception, counter] = this.verifyOutcome(res.Outcome, msg, exception, outcome, counter);
                        file = ProjArtifacts.getUnitMergedCCovHTML(modelName, mode);
                        msg = ['Cumulative Model Coverage Report not created for: ', modelName];
                        [outcome, exception, counter] = this.verifyFile(file, msg, exception, outcome, counter);
                    else
                        data(i,:) = {modelName, [], [], [], [], []};
                    end
                end
                
                % Capture summary table data.
                this.TaskResults('taskMergeCodeCoverage') = {title, headers, data};
                
                % Capture execution outcome.
                this.TaskOutcomes('taskMergeCodeCoverage') = outcome;
                this.TaskExceptions('taskMergeCodeCoverage') = exception;
            catch ME
                % Throw exception if an error occurs.
                rethrow(ME);
            end
        end
        
        function taskCheckCompModelStds(this)
            % This test point checks if Model Advisor Reports generated
            % from models are successfully created by "checkModelStds".
            
           
            outcome = 1;
            exception = '';
            counter = 0;
            try
                % Test generation of Model Advisor Reports from models in
                % the project.
                title = 'Modeling Standards (Integration)';
                headers = {'Model Name', 'Num Pass', 'Num Warn', 'Num Fail', 'Outcome'};
                data = {};
                for i = 1:numel(this.CompModelNames)
                    modelName = this.CompModelNames{i};
                    % Remove cache if it exists.
                    if exist(fullfile(this.ProjectDir, 'work', 'cache', 'slprj', 'modeladvisor', modelName), 'dir')
                        rmdir(fullfile(this.ProjectDir, 'work', 'cache', 'slprj', 'modeladvisor', modelName), 's');
                    end
                    if this.isTopModel(modelName)
                        res = checkModelStds(modelName, 'TreatAsTopMdl', 'CI','CompositeComponent');
                    else
                        res = checkModelStds(modelName, [], 'CI','CompositeComponent');
                    end
                    data(i,:) = {modelName, res.NumPass, res.NumWarn, res.NumFail, res.Outcome};
                    msg = ['One or more modeling standard violations found on ', modelName, '.'];
                    [outcome, exception, counter] = this.verifyOutcome(res.Outcome, msg, exception, outcome, counter);
                    file = ProjArtifacts.getCompMStdChksHTML(modelName);
                    msg = ['Model Advisor Report not created for: ', modelName];
                    [outcome, exception, counter] = this.verifyFile(file, msg, exception, outcome, counter);
                end
                
                % Capture summary table data.
                this.TaskResults('taskCheckCompModelStds') = {title, headers, data};
                
                % Capture execution outcome.
                this.TaskOutcomes('taskCheckCompModelStds') = outcome;
                this.TaskExceptions('taskCheckCompModelStds') = exception;
            catch ME
                % Throw exception if an error occurs.
                rethrow(ME);
            end
        end
        
    end
    
end
