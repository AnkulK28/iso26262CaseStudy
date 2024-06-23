classdef JenkinsReport
    %JenkinsReport Generate a Jenkins XML Summary Report
    %   Generate an XML report for use by the Jenkins Summary Display
    %   Plugin to publish results. For more information, see
    %   https://wiki.jenkins.io/display/JENKINS/Summary+Display+Plugin
    
    % Copyright 2020 The MathWorks, Inc.
    
    properties
    end
    
    methods
        function obj = JenkinsReport()
            % Constructor for JenkinsReport.
        end
    end
    
    methods(Static)
        function createSummary(job)
            % Create an XML file for use by the Jenkins Summary Display
            % Plugin to summarize the outcome of the entire build job.
            import matlab.io.xml.dom.*
            docNode = Document('section');
            sectionNode = docNode.getDocumentElement();
            sectionNode.setAttribute('name', 'Build Summary');
            if job.TaskResults.isKey("testOutcomes")
                table = job.TaskResults("testOutcomes"); % Result is a cell of {title, headers, data}.
                JenkinsReport.createTable(docNode, sectionNode, table{2}, table{3});
            end
            writeToFile(DOMWriter, docNode, fullfile(job.ReportDir, 'BuildSummaryTable.xml'));
        end
        
        function createTables(job)
            % Create an XML file for use by the Jenkins Summary Display
            % Plugin to summarize the outcomes of critical verification
            % tasks.
            import matlab.io.xml.dom.*
            docNode = Document('section');
            tabsNode = docNode.createElement('tabs');
            sectionNode = docNode.getDocumentElement();
            sectionNode.setAttribute('name', 'Verification Result Summary');
            sectionNode.appendChild(tabsNode);
            for i = 1:numel(job.TaskSequence)
                if job.TaskResults.isKey(job.TaskSequence{i})
                    table = job.TaskResults(job.TaskSequence{i}); % Each result is a cell of {title, headers, data}.
                    % Create a new tab.
                    tabNode = docNode.createElement('tab');
                    tabNode.setAttribute('name', table{1});
                    tabsNode.appendChild(tabNode);
                    JenkinsReport.createTable(docNode, tabNode, table{2}, table{3});
                end
            end
            writeToFile(DOMWriter, docNode, fullfile(job.ReportDir, 'VerificationSummaryTables.xml'));
        end
        
        function createTable(docNode, node, headers, data)
            % Create a table based on given headers and data.
            
            % Create a new table.
            tableNode = docNode.createElement('table');
            tableNode.setAttribute('sorttable', 'yes');
            node.appendChild(tableNode);
            
            % Create a row for headers.
            rowNode = docNode.createElement('tr');
            tableNode.appendChild(rowNode);
            for i = 1:numel(headers)
                dataNode = docNode.createElement('td');
                dataNode.setAttribute('value', headers{i});
                rowNode.appendChild(dataNode);
            end
            
            % Create a row for each model.
            for i = 1:size(data,1)
                rowNode = docNode.createElement('tr');
                tableNode.appendChild(rowNode);
                for j = 1:size(data,2)
                    dataNode = docNode.createElement('td');
                    if ~isempty(data{i,j})
                        if isnumeric(data{i,j})
                            if isDataArray(data{i,j})
                                % Coverage data.
                                dataNode.setAttribute('value', [num2str(data{i,j}(1)), '/', num2str(data{i,j}(2))]);
                            else
                                dataNode.setAttribute('value', num2str(data{i,j}));
                            end
                        else
                            dataNode.setAttribute('value', data{i,j});
                        end
                    else
                        dataNode.setAttribute('value', '-');
                    end
                    % Set cell color based on the "Outcome".
                    if strcmpi(headers{j}, 'Outcome')
                        if data{i,j} == -1
                            dataNode.setAttribute('bgcolor', 'red');
                        elseif data{i,j} == 0
                            dataNode.setAttribute('bgcolor', 'orange');
                        elseif data{i,j} == 1
                            dataNode.setAttribute('bgcolor', 'green');
                        else
                            % No color.
                        end
                    end
                    rowNode.appendChild(dataNode);
                end
            end
        end
    end
    
end
