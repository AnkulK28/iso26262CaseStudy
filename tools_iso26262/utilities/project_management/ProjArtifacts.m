classdef ProjArtifacts
    % ProjArtifacts Defines all expected folder paths for project
    %   The ProjectArtifacts class has detailed information about the
    %   target paths for each artifact. It can be referred to as a central
    %   location to interrogate this information.
    
    methods (Access = private)
        function obj = ProjArtifacts
        end
    end
    
    properties (Constant)
        prjRoot = simulinkproject().RootFolder();                               % Path to project root
        workPath = fullfile(ProjArtifacts.prjRoot, 'work');                     % Path to working dir folder
        webviewsPath = fullfile(ProjArtifacts.prjRoot, 'work', 'webviews');     % Path to webviews folder
        dashboardsPath = fullfile(ProjArtifacts.prjRoot, 'work', 'dashboards'); % Path to dashboards
        cachePath = fullfile(ProjArtifacts.workPath, 'cache');                  % Path to cache folder
        isoTools = 'tools_iso26262';                                            % Name of ISO 26262 tools folder
        misraCfg = fullfile(ProjArtifacts.prjRoot, ...                          % Path to MISRA ACG config
            ProjArtifacts.isoTools, 'checks', 'MISRA_C_2012_ACG.xml');
        metricsJson = fullfile(ProjArtifacts.prjRoot,...                        % Path to Model Advisor metrics config
            ProjArtifacts.isoTools, 'checks', 'modelMetrics.json');
        maUnitChecksJson = fullfile(ProjArtifacts.prjRoot, ...                  % Path to ISO 26262 Model Advisor Checks for SW units
            ProjArtifacts.isoTools, 'checks', 'iso26262Checks.json');
        maIntegrationChecksJson = fullfile(ProjArtifacts.prjRoot, ...           % Path to ISO 26262 Model Advisor Checks for Integration Components
            ProjArtifacts.isoTools, 'checks', 'iso26262IntegrationChecks.json');
        
        prevRMIPrefs = fullfile(ProjArtifacts.prjRoot,'work','prev_rmipref_data.mat');  % Name of MAT file storing RMI preferences before opening project
        
        modelTemplate = 'iso26262ModelTemplate.sltx';                            %Name of ISO 26262 model template (the basis for all design models)
        
        %% Continuous Integartion
        CI_UG = fullfile(ProjArtifacts.prjRoot, 'continuous_integration','help','User_Guide.docx');     %path to CI user guide
        
        %% SW planning
        SWDevEnvTemplate = fullfile(ProjArtifacts.prjRoot, ...
            'ISO_06_05_SwDevEnv', ...
            'WPs', ...
            'ISO_6_5_5_1_SwDevEnvDoc',...
            'SoftwareDevelopmentEnvironmentTemplate.docx');
        %% Path to SW Architecture
        SWArchPath = fullfile(ProjArtifacts.prjRoot, ...
            'ISO_06_07_SwArcDes',...
            'WPs', ...
            'ISO_6_7_5_1_SwArcDesSpec' ...
            );
        
        %% Path to SW Unit Design folders
        unitDesignPath = fullfile(ProjArtifacts.prjRoot, ...
            'ISO_06_08_SwU',...
            'WPs', ...
            'ISO_6_8_5_1_SwUnDesSpec'...
            );
        
        %% Path to code generation folders (for units and components)
        unitCodeGenPath = fullfile(ProjArtifacts.prjRoot, ...
            'ISO_06_08_SwU',...
            'WPs', ...
            'ISO_6_8_5_2_Impl'...
            );
        
        %% Path to SW Unit Verification folders
        unitVerifSpecPath = fullfile(ProjArtifacts.prjRoot, ...
            'ISO_06_09_SwUVer',...
            'WPs', ...
            'ISO_6_9_5_1_SwVerSpec'...
            );
        
        %% Path to unit verification results
        unitVerifResultsPath = fullfile(ProjArtifacts.prjRoot, ...
            'ISO_06_09_SwUVer',...
            'WPs', ...
            'ISO_6_9_5_2_SwVerRprt'...
            );
        
        %% Path to SW Integration folders
        compIntegrationPath = fullfile(ProjArtifacts.prjRoot, ...
            'ISO_06_10_SwIntgr',...
            'WPs', ...
            'ISO_6_10_5_2_SwEmb'...
            );
        
        %% Path to integration verification specification
        compVerifSpecPath = fullfile(ProjArtifacts.prjRoot, ...
            'ISO_06_10_SwIntgr',...
            'WPs', ...
            'ISO_6_10_5_1_SwVerSpec'...
            );
        
        %% Path to integration verification results
        compVerifResultsPath = fullfile(ProjArtifacts.prjRoot, ...
            'ISO_06_10_SwIntgr',...
            'WPs', ...
            'ISO_6_10_5_3_SwVerRprt'...
            );
        
        %% Path to Technical Safety Requirments Specification
        TSRS = fullfile(ProjArtifacts.prjRoot,...
            'ISO_04',...
            'ISO_4_6_5_1_TechSafReqSpec'...
            );
        
        %% Path to System Architecture Design Specification
        SysArch = fullfile(ProjArtifacts.prjRoot,...
            'ISO_04',...
            'ISO_4_6_5_3_SysArcDesSpec'...
            );
        
        %% Path to Software Safety Requirments Specification
        SSRS = fullfile(ProjArtifacts.prjRoot,...
            'ISO_06_06_SwSafReq',...
            'WPs', ...
            'ISO_6_6_5_1_SwSafReqSpec'...
            );
        
        
        %% Path to Shared utility folder for auto generated code
        SharedUtilityPath = fullfile(ProjArtifacts.unitCodeGenPath,...
            'slprj',...
            'ert',...
            '_sharedutils');
    end
    
    methods (Static)
        
        function singleObj = getInstance
            % return the singleton instance of ProjArtifacts
            persistent localObj
            if isempty(localObj)
                localObj = ProjArtifacts;
            end
            singleObj = localObj;
        end
        
        %% Requirement Files
        function f = getTSRS()
            % get path to techncial safety requirements specification
            f = ProjArtifacts.TSRS;
        end
        
        function f = getSSRS()
            % get path to software safety requirements specification
            f = ProjArtifacts.SSRS;
        end
        
        
        function f = getReqReport(reqSetName)
            % get path to report generated from a requirement sets
            f = fullfile(fileparts(which([reqSetName, '.slreqx'])), [reqSetName, '_ReqReport.docx']);
        end
        
        %% Architectures
        function f = getSysArchFolder()
            % get the system architecture folder
            f = fullfile(ProjArtifacts.SysArch);
        end
        
        function f = getSWArchPath()
            % get path to the software architecture
            f = fullfile(ProjArtifacts.SWArchPath);
        end
        
        function f = getUnitDesignPath(modelName)
            % get path to a software unit design folder on the basis of its
            % model name.
            f= fullfile(ProjArtifacts.unitDesignPath, modelName);
        end
        function f = getCompDesignPath(modelName)
            % get path to a SW component design based on its model name
            f= fullfile(ProjArtifacts.compIntegrationPath, modelName);
        end
        
        function f = getModelDesignRpt(modelName)
            % get design report for a specific model
            f = fullfile(fileparts(which(modelName)), ...
                'documents', [modelName '_SDD']);
        end
        
        
        %% Unit Verification Specification
        function f = getUnitVerSpecPath(modelName)
            % get Path to the unit verification specification
            f = fullfile(ProjArtifacts.unitVerifSpecPath, modelName);
        end
        
        function f = getUnitRBTTestFile(modelName)
            % get Requirements-based Test file for a software unit
            f = fullfile(ProjArtifacts.unitVerifSpecPath, modelName, ...
                [modelName '_Test.mldatx']);
        end
        
        function f = getRBTTestHarness(modelName)
            % get Requirements-based Test Harness for a model
            f = fullfile(ProjArtifacts.unitDesignPath, modelName, ...
                [modelName '_Harness.slx']);
        end
        function f = getUnitSLDVTestFile(modelName)
            % get test file generated by SLDV for a software unit
            f = fullfile(ProjArtifacts.unitVerifSpecPath, modelName, ...
                [modelName '_SLDV_Based_Test.mldatx']);
        end
        
        function f = getUnitMergedTestFile(modelName)
            % get test file merged from requirements-based tests and those
            % generated by SLDV for a software unit
            f = fullfile(ProjArtifacts.unitVerifSpecPath, modelName, ...
                [modelName '_Merged_Test.mldatx']);
        end
        
        function f = getUnitSLDVTestGenReport(modelName)
            % get report of test geneneration done by SLDV for a model
            f = fullfile(ProjArtifacts.unitVerifSpecPath, modelName, ...
                [modelName '_Test_Generation_Report.pdf']);
        end
        
        function f = getUnitSLDVTestGenReportHTMLFiles(modelName)
            % get path to HTML files used during SLDV test generation
            f = fullfile(ProjArtifacts.unitVerifSpecPath, modelName, ...
                [modelName '_Test_Generation_Report_html_files']);
        end
        
        function f = getUnitSLDVTestGenReportPDFFiles(modelName)
            % get path to PDF files used during SLDV test generation
            f = fullfile(ProjArtifacts.unitVerifSpecPath, modelName, ...
                [modelName '_Test_Generation_Report_pdf_files']);
        end
        
        function f = getUnitSLDVTestHarness(modelName)
            % get test harness genearted for a unit by SLDV
            f = fullfile(ProjArtifacts.unitDesignPath, modelName, ...
                [modelName '_Harness_SLDV.slx']);
        end
        
        function f = getUnitSLDVTestBaselineDir(modelName)
            % get path to directory containing SLDV test baslines for a
            % unit
            f = fullfile(ProjArtifacts.unitVerifSpecPath, modelName, ...
                'sl_test_baselines');
        end
        
        %% Unit Verification Results
        function f = getUnitVerResultsPath(modelName)
            % get path to software unit verification results
            f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName);
        end
        
        % MIL simulation results
        function f = getUnitMILResultsBaseName(modelName)
            % get base name of result file of unit requirement-based testing in 
            % model-in-the-loop simulation (MIL)
            f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'mil', modelName);
        end
        function f = getUnitMILResultsHLRFile(modelName)
            % get full path to the result file (.mldatx) of unit requirement-based 
            % testing in model-in-the-loop simulation (MIL).
            f = [ProjArtifacts.getUnitMILResultsBaseName(modelName) '_HLR.mldatx'];
        end
        function f = getUnitMILResultsHLRPDF(modelName)
            % get full path to the result file (.pdf) of unit requirement-based 
            % testing in model-in-the-loop simulation (MIL).
            f = [ProjArtifacts.getUnitMILResultsBaseName(modelName) '_HLR.pdf'];
        end
        function f = getUnitMILResultsHLRDoc(modelName)
            % get full path to the result file (.docx) of unit requirement-based 
            % testing in model-in-the-loop simulation (MIL).
            f = [ProjArtifacts.getUnitMILResultsBaseName(modelName) '_HLR'];
        end
        
        function f = getUnitMILResultsLLRFile(modelName)
            % get full path to the result file (.mldatx) of unit testing 
            % from SLDV-generated tests in model-in-the-loop simulation (MIL).
            f = [ProjArtifacts.getUnitMILResultsBaseName(modelName) '_LLR.mldatx'];
        end
        function f = getUnitMILResultsLLRPDF(modelName)
            % get full path to the result file (.pdf) of unit testing 
            % from SLDV-generated tests in model-in-the-loop simulation (MIL).
            f = [ProjArtifacts.getUnitMILResultsBaseName(modelName) '_LLR.pdf'];
        end
        function f = getUnitMILResultsLLRDoc(modelName)
            % get full path to the result file (.docx) of unit testing 
            % from SLDV-generated tests in model-in-the-loop simulation (MIL).
            f = [ProjArtifacts.getUnitMILResultsBaseName(modelName) '_LLR'];
        end
        
        % MIL Coverage
        function f = getUnitMCovBaseName(modelName)
            % get base name of model coverage of a specific software unit
            f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'mCovs', modelName);
        end
        
        function f = getUnitMCovGifs(modelName)
            % get path to gif files used in model coverage reports for a
            % software unit
            f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'mCovs', 'scv_images');
        end
        
        function f = getUnitMCovHLRHTML(modelName)
            % get path to model coverage report (HTML) of a software unit
            % obtained from requirements-based testing
            f = [ProjArtifacts.getUnitMCovBaseName(modelName) '_HLR_MCov.html'];
        end
        
        function f = getUnitMCovHLRCvt(modelName)
            % get path to model coverage report (cvt) of a software unit
            % obtained from requirements-based testing
            f = [ProjArtifacts.getUnitMCovBaseName(modelName) '_HLR_MCov.cvt'];
        end
        
        function f = getUnitMCovLLRHTML(modelName)
            % get path to model coverage report (HTML) of a software unit
            % obtained from testing with SLDV-generated tests
            f = [ProjArtifacts.getUnitMCovBaseName(modelName) '_LLR_MCov.html'];
        end
        
        function f = getUnitMCovLLRCvt(modelName)
            % get path to model coverage report (.cvt) of a software unit
            % obtained from testing with SLDV-generated tests
            f = [ProjArtifacts.getUnitMCovBaseName(modelName) '_LLR_MCov.cvt'];
        end
        
        function f = getUnitMCovMRGHTML(modelName)
            % get path to model coverage report (HTML) of a software unit
            % obtained from testing with requirements-based and SLDV-generated tests
            f = [ProjArtifacts.getUnitMCovBaseName(modelName) '_MRG_MCov.html'];
        end
        
        function f = getUnitMCovMRGCvt(modelName)
            % get path to model coverage report (cvt) of a software unit
            % obtained from testing with requirements-based and SLDV-generated tests
            f = [ProjArtifacts.getUnitMCovBaseName(modelName) '_MRG_MCov.cvt'];
        end
        
        % Model Std checks
        function f = getUnitMStdChksHTML(modelName)
            % get path to model advisor report (HTML) for compliance with modeling
            % guidelines for a software unit
            f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'mStdChks', ...
                [modelName '_SMS_Conformance_Report.html']);
        end
        
        function f = getCompMStdChksHTML(modelName)
            % get path to model advisor report (HTML) for compliance with modeling
            % guidelines for an integration software component
            f = fullfile(ProjArtifacts.compVerifResultsPath, modelName, 'mStdChks', ...
                [modelName '_SMS_Conformance_Report.html']);
        end
        
        % model Metrics
        function f = getUnitModelMetricsHTML(modelName)
            % get path to model advisor report (HTML) for model metrics
            % for a software unit
            f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'mMetrics', ...
                [modelName '_MMetrics.html']);
        end
        function f = getUnitModelMetricsPDF(modelName)
            % get path to model advisor report (PDF) for model metrics
            % for a software unit
            f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'mMetrics', ...
                [modelName '_MMetrics.pdf']);
        end
        % Model Design Error Detection
        function f = getUnitDesErrsBaseName(modelName)
            % get base name for design error detection reports for a
            % software unit
            f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'mDesErrs', ...
                [modelName '_DesErrs']);
        end
        function f = getUnitDesErrsHTML(modelName)
            % get full path of design error detection report (HTML) for a
            % software unit
            f = [ProjArtifacts.getUnitDesErrsBaseName(modelName) '.html'];
        end
        function f = getUnitDesErrsPDF(modelName)
            % get full path of design error detection report (PDF) for a
            % software unit
            f = [ProjArtifacts.getUnitDesErrsBaseName(modelName) '.pdf'];
        end
        
        function f = getCompDesErrsBaseName(modelName)
            % get base name for design error detection reports for an
            % integration software component
            f = fullfile(ProjArtifacts.compVerifResultsPath, modelName, 'mDesErrs', ...
                [modelName '_DesErrs']);
        end
        function f = getCompDesErrsHTML(modelName)
            % get full path of design error detection report (HTML) for an
            % integration software component
            f = [ProjArtifacts.getCompDesErrsBaseName(modelName) '.html'];
        end
        function f = getCompDesErrsPDF(modelName)
            % get full path of design error detection report (PDF) for an
            % integration software component
            f = [ProjArtifacts.getCompDesErrsBaseName(modelName) '.pdf'];
        end
        
        %% Unit Code generation
        function f = getUnitImplPath(modelName)
            % get path for folder containing automatically generated code
            % for a specific model
            f = fullfile(ProjArtifacts.unitCodeGenPath, ...
                'slprj', ...
                'ert', ...
                modelName);
        end
        
        function f = getImplPathHTML(modelName, isTopModel)
            % get path to code generation report for a specific model.
            % isTopModel can be either true|false
            if (nargin<2)
                isTopModel = false;
            end
            if(isTopModel)
                f = fullfile(ProjArtifacts.unitCodeGenPath, ...
                    [modelName '_ert_rtw'], ...
                    'html',...
                    'index.html');
%                     [modelName, '_codegen_rpt.html']); %prior to R21b
            else
                f = fullfile(ProjArtifacts.unitCodeGenPath, ...
                    'slprj', ...
                    'ert', ...
                    modelName, ...
                    'html',...
                    'index.html');
%                     [modelName, '_codegen_rpt.html']);  %prior to R21b
            end
        end
        function f = getSharedUtilityPath()
            % get path to folder containing generated shared utility code
            f = fullfile(ProjArtifacts.unitCodeGenPath,...
                'slprj', ...
                'ert', ...
                '_sharedutils');
        end
        
        %% Check Code Standards
        function f = getUnitCStdChksPDF(modelName)
            % get path to code MISRA conformance report (PDF) for a
            % specific unit
            f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'cStdChks', ...
                [modelName '_SCS_Conformance_Report.pdf']);
        end
        
        function f = getUnitCStdChksWord(modelName)
            % get path to code MISRA conformance report (.docx) for a
            % specific unit
            f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'cStdChks', ...
                [modelName '_SCS_Conformance_Report.docx']);
        end
        
        function f = getUnitCStdChksSummaryPDF(modelName)
            % get path to bug finder summary report (PDF) for a software
            % unit
            f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'cStdChks', ...
                [modelName '_Bug_Finder_Summary.pdf']);
        end
        
        function f = getUnitCStdChksSummaryWord(modelName)
            % get path to bug finder summary report (.docx) for a software
            % unit
            f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'cStdChks', ...
                [modelName '_Bug_Finder_Summary.docx']);
        end

        function f = getUnitCStdChksPSproj(modelName)
            % get polyspace project file used to run MISRA compliance
            % checks
            f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'cStdChks', ...
                [modelName, '_CodingRulesOnly_config.psprj']);
        end
        function f = getUnitCStdChksTempPSproj(modelName,isModelRef)
            % get temporary polyspace project file in cache folder used to 
            % run MISRA compliance checks
            if nargin<2
                isModelRef = true;
            end
            if isModelRef
                f = fullfile(ProjArtifacts.cachePath, ['ps_mr_', modelName]);
            else
                f = fullfile(ProjArtifacts.cachePath, ['ps_', modelName]);
            end
        end
        
        %% SIL/PIL Simulations Instrumented/Uinstrumented
        function f = getUnitSPILRBTResBaseName(modelName, mode, isInstrumented)
            % get base name of requirement-based testing result reports
            % when run with generated code of a software unit. mode can be either 'SIL'|'PIL'.
            % isInstrumented can be either true|false
            if strcmpi(mode, 'SIL')
                subFolder = 'host';
            else
                subFolder = 'target';
            end
            if isInstrumented
                f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'cspil', ...
                    subFolder, 'HLR', 'instr', ...
                    [modelName '_INSTR_' mode '_HLR']);
            else
                f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'cspil', ...
                    subFolder, 'HLR', 'uninstr', ...
                    [modelName mode '_HLR']);
            end
        end
        
        function f = getUnitSPILRBTResFile(modelName, mode, isInstrumented)
            % get testing results (.mldatx) of requirement-based testing
            % when run with generated code of a software unit. mode can be either 'SIL'|'PIL'.
            % isInstrumented can be either true|false
            f = [ProjArtifacts.getUnitSPILRBTResBaseName(modelName, mode, isInstrumented) '.mldatx'];
        end
        
        function f = getUnitSPILRBTResPDF(modelName, mode, isInstrumented)
            % get testing results (.mldatx) of requirement-based testing
            % when run with generated code of a software unit. mode can be either 'SIL'|'PIL'.
            % isInstrumented can be either true|false
            f = [ProjArtifacts.getUnitSPILRBTResBaseName(modelName, mode, isInstrumented) '.pdf'];
        end
        
        function f = getUnitSPILLLRResBaseName(modelName, mode, isInstrumented)
            % get base name of result reports obtained by executing tests
            % generated by SLDV when run with generated code of a software 
            % unit. mode can be either 'SIL'|'PIL'. isInstrumented can be 
            % either true|false
            if strcmpi(mode, 'SIL')
                subFolder = 'host';
            else
                subFolder = 'target';
            end
            if isInstrumented
                f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'cspil', ...
                    subFolder, 'LLR', 'instr', ...
                    [modelName '_INSTR_' mode '_LLR']);
            else
                f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'cspil', ...
                    subFolder, 'LLR', 'uninstr', ...
                    [modelName mode '_LLR']);
            end
        end
        
        function f = getUnitSPILLLRResFile(modelName, mode, isInstrumented)
            % get testing results (.mldatx) of testing with SLDV-generated
            % tests when run with generated code of a software unit. 
            % mode can be either 'SIL'|'PIL'. isInstrumented can be either
            % true|false
            f = [ProjArtifacts.getUnitSPILLLRResBaseName(modelName, mode, isInstrumented) '.mldatx'];
        end
        
        function f = getUnitSPILLLRResPDF(modelName, mode, isInstrumented)
            % get testing results (.pdf) of testing with SLDV-generated
            % tests when run with generated code of a software unit. 
            % mode can be either 'SIL'|'PIL'. isInstrumented can be either
            % true|false
            f = [ProjArtifacts.getUnitSPILLLRResBaseName(modelName, mode, isInstrumented) '.pdf'];
        end
        
        % SIL/PIL Code Coverage
        function f = getUnitRBTCCovBaseName(modelName, mode)
            % get base name of report for code coverage obtained from
            % requirements-based testing. mode can be 'SIL'|'PIL'
            if strcmpi(mode, 'SIL')
                subFolder = 'host';
            else
                subFolder = 'target';
            end
            f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'cCovs', ...
                subFolder, 'HLR', ...
                [modelName '_HLR_CCov']);
        end
        
        function f = getUnitRBTCCovHTML(modelName, mode)
            % get full path of HTML report for code coverage obtained from
            % requirements-based testing. mode can be 'SIL'|'PIL'
            f = [ProjArtifacts.getUnitRBTCCovBaseName(modelName, mode) '.html'];
        end
        
        function f = getUnitRBTCCovCvt(modelName, mode)
            % get full path of .cvt report for code coverage obtained from
            % requirements-based testing. mode can be 'SIL'|'PIL'
            f = [ProjArtifacts.getUnitRBTCCovBaseName(modelName, mode) '.cvt'];
        end
        
        function f = getUnitLLRCCovBaseName(modelName, mode)
            % get base name of report for code coverage obtained from
            % test cases generated by SLDV. mode can be 'SIL'|'PIL'. mode 
            % can be 'SIL'|'PIL'
            if strcmpi(mode, 'SIL')
                subFolder = 'host';
            else
                subFolder = 'target';
            end
            f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'cCovs', ...
                subFolder, 'LLR', ...
                [modelName '_LLR_CCov']);
        end
        
        function f = getUnitLLRCCovHTML(modelName, mode)
            % get full path of HTML report for code coverage obtained from
            % test cases generated by SLDV. mode can be 'SIL'|'PIL'
            f = [ProjArtifacts.getUnitLLRCCovBaseName(modelName, mode) '.html'];
        end
        
        function f = getUnitLLRCCovCvt(modelName, mode)
            % get full path of .cvt report for code coverage obtained from
            % test cases generated by SLDV. mode can be 'SIL'|'PIL'
            f = [ProjArtifacts.getUnitLLRCCovBaseName(modelName, mode) '.cvt'];
        end
        
        function f = getUnitMergedCCovBaseName(modelName, mode)
            % get base name of report for merged code coverage obtained from
            % test cases of requirement-based testing and those generated 
            % by SLDV. mode can be 'SIL'|'PIL'
            if strcmpi(mode, 'SIL')
                subFolder = 'host';
            else
                subFolder = 'target';
            end
            f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'cCovs', ...
                subFolder, 'MRG', ...
                [modelName '_MRG_CCov']);
        end
        
        function f = getUnitMergedCCovHTML(modelName, mode)
            % get full path of HTML report for code coverage obtained from
            % test cases of requirement-based testing and those generated 
            % by SLDV. mode can be 'SIL'|'PIL'
            f = [ProjArtifacts.getUnitMergedCCovBaseName(modelName, mode) '.html'];
        end
        
        function f = getUnitMergedCCovCvt(modelName, mode)
            % get full path of .cvt report for code coverage obtained from
            % test cases of requirement-based testing and those generated 
            % by SLDV. mode can be 'SIL'|'PIL'
            f = [ProjArtifacts.getUnitMergedCCovBaseName(modelName, mode) '.cvt'];
        end
        
        function f = getUnitCCovGifs(modelName, mode)
            % get path to folder containing gif files used in coverage
            % reports. mode can be 'SIL'|'PIL'
            if strcmpi(mode, 'SIL')
                subFolder = 'host';
            else
                subFolder = 'target';
            end
            f = fullfile(ProjArtifacts.unitVerifResultsPath, modelName, 'cCovs', ...
                subFolder, 'LLR', ...
                'scv_images');
        end
           
        
        %% Component
        function f = getCompVerSpecPath(modelName)
            % get path to a software component verification specification
            f = fullfile(ProjArtifacts.compVerifSpecPath, modelName);
        end
        function f = getCompVerResultsPath(modelName)
            % get path to a software component verification results
            f = fullfile(ProjArtifacts.compVerifResultsPath, modelName);
        end
        function f = getCompRBTTestFile(modelName)
            % get path to the requirement-based test file for a  software
            % component
            f = fullfile(ProjArtifacts.getCompVerSpecPath(modelName), ...
                [modelName '_Test.mldatx']);
        end
        function f = getCompSLDVTestFile(modelName)
            % get path to the test file created by SLDV for a  software
            % component
            f = fullfile(ProjArtifacts.getCompVerSpecPath(modelName), ...
                [modelName '_SLDV_Based_Test.mldatx']);
        end
        function f = getCompMergedTestFile(modelName)
            % get path to the test file merging test cases from the
            % requirement-based testing and from SLDV generated tests
            f = fullfile(ProjArtifacts.compVerifSpecPath, modelName, ...
                [modelName '_Merged_Test.mldatx']);
        end

        
        %% get All Software Unit names in project
        function unitNames = getAllUnitNames()
            dirList = dir(ProjArtifacts.unitDesignPath);
            % Ignore names that are not a folder such as ".", ".."
            ignoreDir = arrayfun(@(x) (x.isdir == 0) || contains(x.name, '.'), dirList);
            unitNames = dirList(~ignoreDir);
            unitNames = string({unitNames.name});
        end
    end
end
