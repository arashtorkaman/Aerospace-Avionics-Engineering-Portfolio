function fig = plot_state_response(response, figureTitle)
%PLOT_STATE_RESPONSE Plot u, w, q, and theta versus time.
%
% Values are plotted in the units declared by 02_data.
% The function does not silently convert state units.

    arguments
        response struct
        figureTitle (1,1) string = "Longitudinal State Response"
    end

    t = response.time_s;
    x = response.states;

    if size(x,2) ~= 4
        error("Phase1:UnexpectedResponseSize", ...
            "Expected four state outputs.");
    end

    fig = figure("Name", figureTitle);
    tiledlayout(2,2);

    for k = 1:4
        nexttile;
        plot(t, x(:,k), "LineWidth", 1.2);
        grid on;
        xlabel("Time [s]");

        stateName = string(response.state_names(k));
        stateUnit = string(response.state_units(k));

        ylabel(sprintf("%s [%s]", stateName, stateUnit));
        title(stateName);
    end

    sgtitle(figureTitle);
end
