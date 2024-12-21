clear
clc

multiplier = 70;
constantMult = 30;
bChange = 0.15;

deviceReader = audioDeviceReader;
setup(deviceReader)

clf

f = figure("Position", [0 0 1707 1009], "Color", [0 0 0], "WindowStyle", "normal", "NumberTitle", "off");
f.Name = "Decibel Meter amd Wave Analyzer";

f.HandleVisibility = 'off';

close all

f.HandleVisibility = 'on';

layout = tiledlayout(2,3);

ax = nexttile([1 3]);

hold(ax,"on");


b = 0;
clear arr;
arr = deviceReader();
arrMin = -min(arr)*multiplier + constantMult;
arrMax = max(arr)*multiplier + constantMult;

a1 = annotation('textbox', [0.65, 0.40, 0.3, 0.1], 'String', "Decibel level (dB): " + arrMax);
a1.FontSize = 30;
a1.LineStyle = 'none';
a1.FitBoxToText = 'off';
a1.FontName = 'Bookman';

line1 = line(b, arrMax, "Color", "b", "LineWidth", 4);
lastMax = plot(ax, b, arrMax, "r*");
lastMaxInfo = arrMax;

maxYLine = yline(ax, arrMax, "Color", "w");

line2 = line(b, arrMin, "Color", "r");
lastMin = plot(ax, b, arrMin, "r*");
lastMinInfo = arrMin;

minYLine = yline(ax, arrMin, "Color", "w");

axis(ax, [0 inf -inf inf]);
hold on;

ax2 = nexttile([1 2]);
plot(ax2, arr, "b-");


title(ax,"Decibel (Loudness) Meter");
xlabel(ax, "Time (s)");
ylabel(ax, "Loudness (dB)");

ax2y1 = ylabel(ax2, "Amplitude (At 44.1 kHz)");
ylabelPos = ax2y1.Position(1);

b = b + bChange;
one = 1;
two = 1;
three = 1;

disp("Loop starting.")

gtic = tic;

frames = 0;
samples = 0;


for idx = 1:100
    clear arr;
    b = 0;
    
    tic
    while toc < 120
        xlim(ax2, [0 1024]);
        title(ax2, "Wave Analyzer");
        ax2xl = xlabel(ax2, "Sample Number");
        
        ax2y1 = ylabel(ax2, "Amplitude (At 44.1 kHz)");
        ax2y1.Position(1) = ylabelPos - 5;
        a1.String = ["Instantaneous decibel level", "(dB):", num2str((arrMax+arrMin)/2), "", "Runtime (s):", num2str(toc(gtic)+(idx-1)*120), "", "Total frames/samples:", num2str(frames) + "/" + num2str(samples), "", "*Graph resets every 120 s"];
        
        clear arr
        
        pause(bChange);
        
        arr = deviceReader()*multiplier; %+ constantMult;
        frames = frames+1;
        samples = samples+1024;
        
        plot(ax2, arr);
        
        b = toc;
        
        arrMax = max(arr) + constantMult;
        arrMin = -min(arr) + constantMult;
        
        line1.XData = [line1.XData, toc(gtic)+(idx-1)*120];
        line1.YData = [line1.YData, arrMax];
        line2.XData = [line2.XData, toc(gtic)+(idx-1)*120];
        line2.YData = [line2.YData, arrMin];
        
        [totalMax, totMaxIdx] = max(line1.YData);
        [totalMin, totMinIdx] = max(line2.YData);
        
        
        if totalMax > lastMaxInfo
            delete(lastMax);
            lastMax = plot(ax, line1.XData(totMaxIdx), totalMax, "r*");
            lastMaxInfo = totalMax;
            
            delete(maxYLine);
            maxYLine = yline(ax, totalMax, "Color", "w");
        end
        
        if totalMin > lastMinInfo
            delete(lastMin)
            lastMin = plot(ax, line2.XData(totMinIdx), totalMin, "r*");
            lastMinInfo = totalMin;
            
            delete(minYLine);
            minYLine = yline(ax, totalMin, "Color", "w");
        end
        
        b = b+bChange;
    end
    
    lastMinInfo = constantMult;
    lastMaxInfo = multiplier;
    
    
    delete(line1);
    delete(line2);
    
    hold(ax,"on");
    
    currTime = toc(gtic)+(idx)*120;
    
    axis(ax, [currTime inf 45 55]);
    
    line1 = line(ax, currTime, 50, "Color", "b", "LineWidth", 4);
    
    line2 = line(ax, currTime, 50, "Color", "r");
    
    axis(ax, [currTime inf -inf inf]);
    
    line1.XData = [];
    line1.YData = [];
    line2.XData = [];
    line2.YData = [];
end

xlim(ax2, [0 1022]);
title(ax2, "Wave Analyzer");
xlabel(ax2, "Sample Number");
ylabel(ax2, "Amplitude (At 44.1 kHz)");
disp("Ended.")
