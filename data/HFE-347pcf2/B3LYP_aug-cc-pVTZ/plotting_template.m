% Read data from first .dat file
data1 = readmatrix('HITRAN_340_data.dat');  % Replace 'file1.dat' with your first filename
x1 = data1(:,1);  % First column as x
y1 = data1(:,2);  % Second column as y

% Read data from second .dat file
data2 = readmatrix('theoretical_CS_340_GFE_CALIBRATED.dat');  % Replace 'file2.dat' with your second filename
x2 = data2(:,1);  % First column as x
y2 = data2(:,2);  % Second column as y

% Plot both datasets
plot(x1, y1, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Hitran');
hold on;
plot(x2, y2, 'r--', 'LineWidth', 1.5, 'DisplayName', 'ORC ');
hold off;

% Add legend
legend show;
legend('Location', 'best');  % Places legend in best location automatically

% Create text box for coordinate display
coordText = annotation('textbox', [0.15, 0.8, 0.2, 0.05], ...
    'String', 'Move mouse over plot', ...
    'EdgeColor', 'black', ...
    'BackgroundColor', 'white', ...
    'FontSize', 10);

% Set up mouse motion callback
set(fig, 'WindowButtonMotionFcn', @(src, event) mouseMoveCallback(src, event, [h1, h2], coordText));

% Mouse motion callback function
function mouseMoveCallback(~, ~, plotHandles, coordText)
    % Get current mouse position in axes coordinates
    C = get(gca, 'CurrentPoint');
    mouseX = C(1,1);
    mouseY = C(1,2);
    
    % Check if mouse is within axes bounds
    xLim = get(gca, 'XLim');
    yLim = get(gca, 'YLim');
    
    if mouseX >= xLim(1) && mouseX <= xLim(2) && ...
       mouseY >= yLim(1) && mouseY <= yLim(2)
        
        % Find closest dataset
        minDist = inf;
        closestDisplayName = '';
        closestX = mouseX;
        closestY = mouseY;
        
        for i = 1:length(plotHandles)
            xData = get(plotHandles(i), 'XData');
            yData = get(plotHandles(i), 'YData');
            
            % Find closest point on this line
            distances = sqrt((xData - mouseX).^2 + (yData - mouseY).^2);
            [minDistPlot, idx] = min(distances);
            
            % If this point is closer than previous closest
            if minDistPlot < minDist && minDistPlot < 0.5 % Threshold
                minDist = minDistPlot;
                closestDisplayName = get(plotHandles(i), 'DisplayName');
                closestX = xData(idx);
                closestY = yData(idx);
            end
        end
        
        % Update text box
        if ~isempty(closestDisplayName)
            set(coordText, 'String', ...
                {['Dataset: ', closestDisplayName], ...
                 ['X: ', num2str(closestX, '%.3f')], ...
                 ['Y: ', num2str(closestY, '%.3f')]});
        else
            set(coordText, 'String', ...
                {['X: ', num2str(mouseX, '%.3f')], ...
                 ['Y: ', num2str(mouseY, '%.3f')]});
        end
    else
        % Mouse outside axes
        set(coordText, 'String', 'Move mouse over plot');
    end
end

% Optional: Adjust figure size if needed
% set(gcf, 'Position', [100, 100, 800, 600]);