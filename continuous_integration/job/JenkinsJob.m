classdef (Abstract) JenkinsJob < handle
    %JenkinsJob - Abstract class for creating a Jenkins build job
    %   See ISODemoTasks for an example on how to create a CI build job
    %   using this abstract class.
    
    %   Copyright 2021 The MathWorks, Inc.
    
    properties(Abstract)
        TaskSequence
    end
    
    properties
        TaskOutcomes
        TaskExceptions
        TaskResults
    end
    
    methods(Abstract)
        setupJob(obj)
        setupTask(obj)
        cleanupTask(obj)
        cleanupJob(obj)
    end
    
    methods
        function obj = JenkinsJob()
            % Constructor for JenkinsJob.
            obj.TaskOutcomes = containers.Map(obj.TaskSequence, zeros(numel(obj.TaskSequence), 1));
            obj.TaskExceptions = containers.Map(obj.TaskSequence, repmat("", numel(obj.TaskSequence), 1));
            obj.TaskResults = containers.Map();
        end
    end
    
end
