function runJob(job, varargin)
%runJob Run a CI build job
%   Run a CI build job that inherits from the abstract JenkinsJob class.
%   Use an optional argument to define a subset of tasks to execute within
%   the concrete class.
%   runJob(ISODemoTasks)
%   runJob(ISODemoTasks, 'taskVerifyModel2Reqs')
%   runJob(ISODemoTasks, ["taskVerifyModel2Reqs", "taskCheckModelStds", "taskDetectDesignErrs"])

%   Copyright 2021 The MathWorks, Inc.
    cleanupJob = onCleanup(@()job.cleanupJob());
    job.setupJob();
    runTask(job, varargin{:});
    if nargout > 0
        varargout{1} = job;
    else
        createBuildSummary(job);
        rpt = JenkinsReport();
        rpt.createSummary(job);
        rpt.createTables(job);
    end
end

function runTask(job, varargin)
    if nargin > 1 && numel(varargin{1}) == 1
        taskName = varargin{1};
        cleanupTask = onCleanup(@()job.cleanupTask());
        job.setupTask();
        fprintf('*** Task %s started ***\n', taskName);
        try
            job.(taskName);
        catch ME
            % Capture exception if an error occurs.
            job.TaskOutcomes(taskName) = -1;
            job.TaskExceptions(taskName) = ['ERROR: ', ME.message];
            disp(getReport(ME));
            fprintf('*** Task %s terminated due to error ***\n\n\n\n\n', taskName);
            return;
        end
        fprintf('*** Task %s completed ***\n\n\n\n\n', taskName);
    elseif nargin > 1 && numel(varargin{1}) > 1
        taskNames = varargin{1};
        for idx = 1:numel(taskNames)
            runTask(job, taskNames(idx));
        end
    else
        taskNames = job.TaskSequence;
        for idx = 1:numel(taskNames)
            runTask(job, taskNames(idx));
        end
    end
end

function createBuildSummary(job)
    title = 'Build Summary';
    headers = {'Task Name', 'Outcome', 'Warnings/Failures/Errors'};
    data = {};
    for i = 1:numel(job.TaskSequence)
        data(i,:) = {job.TaskSequence(i), job.TaskOutcomes(job.TaskSequence{i}), job.TaskExceptions(job.TaskSequence{i})};
    end
    % Capture summary table data.
    job.TaskResults('testOutcomes') = {title, headers, data};
end
