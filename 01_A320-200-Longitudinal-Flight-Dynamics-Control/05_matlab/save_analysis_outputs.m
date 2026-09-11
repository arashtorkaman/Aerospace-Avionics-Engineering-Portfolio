function save_analysis_outputs( ...
    outputDir, prefix, analysis, response, figPole, figStates, saveOptions)
%SAVE_ANALYSIS_OUTPUTS Save tables, figures, and MAT results.
%
% INPUTS
%   outputDir  - target folder
%   prefix     - filename prefix, e.g. "open_loop"
%   analysis   - output from analyze_longitudinal_modes
%   response   - output from simulate_elevator_step
%   figPole    - pole-map figure handle
%   figStates  - state-response figure handle
%   saveOptions - structure with saveFigures/saveTables/saveMatFile fields

    arguments
        outputDir (1,1) string
        prefix (1,1) string
        analysis struct
        response struct
        figPole
        figStates
        saveOptions struct
    end

    if ~isfolder(outputDir)
        mkdir(outputDir);
    end

    if saveOptions.saveFigures
        saveas(figPole, ...
            fullfile(outputDir, prefix + "_pole_map.png"));

        saveas(figStates, ...
            fullfile(outputDir, prefix + "_state_response.png"));
    end

    if saveOptions.saveTables
        writetable( ...
            analysis.PoleTable, ...
            fullfile(outputDir, prefix + "_pole_table.csv"));

        if ~isempty(analysis.ModeTable)
            writetable( ...
                analysis.ModeTable, ...
                fullfile(outputDir, prefix + "_mode_table.csv"));
        end
    end

    if saveOptions.saveMatFile
        save( ...
            fullfile(outputDir, prefix + "_analysis.mat"), ...
            "analysis", ...
            "response");
    end
end
