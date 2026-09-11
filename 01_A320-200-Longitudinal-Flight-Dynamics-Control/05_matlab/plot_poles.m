function fig = plot_poles(analysis, figureTitle)
%PLOT_POLES Plot eigenvalues in the complex plane.
%
% Stable continuous-time poles lie in the left half-plane.

    arguments
        analysis struct
        figureTitle (1,1) string = "Longitudinal Pole Map"
    end

    poles = analysis.Poles;

    fig = figure("Name", figureTitle);

    plot(real(poles), imag(poles), "x", ...
        "MarkerSize", 10, "LineWidth", 1.5);
    grid on;
    hold on;

    xline(0, "--");
    yline(0, "--");

    xlabel("Real(\lambda) [1/s]");
    ylabel("Imag(\lambda) [rad/s]");
    title(figureTitle);

    for k = 1:numel(poles)
        label = sprintf("  \\lambda_%d", k);
        text(real(poles(k)), imag(poles(k)), label);
    end

    hold off;
end
