function makeGraph(xLabels,yData,yLabel,yLimArray,paperPositionArray, ...
    axisPositionArray,barWidth,labelFont,outputFile,taskName)
    figure('Visible','off','Renderer','zbuffer');
    hold on;
    if(strcmp(taskName,'MIDGraph'))
        for i=1:length(yData)
            if (rem(i,2)==1)
                bar(i,yData(i),'r');
            else
                bar(i,yData(i),'b');
            end
        end
    elseif(strcmp(taskName,'MIDErrorSelect'))
        bar(1:length(yData),yData,barWidth,'g');
    else
        bar(1:length(yData),yData,barWidth);
    end
    if(strcmp(taskName,'errorCompare'))
        plot(1:length(yData),.1*ones(1,length(yData)),'-r','LineWidth',3);
        disp(['Total number of errors < .1: ' num2str(sum(yData<.1)) ' out of ' num2str(length(yData))])
    end
    set(gcf,'Units','centimeters');
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'PaperPosition',paperPositionArray);
    set(gca,'XTick',[]);
    if(length(axisPositionArray)==4)
        set(gca,'units','centimeters','position',axisPositionArray);
    end
    ylabel(yLabel);
    if(length(yLimArray)==2)
        ylim('manual');
        ylim(yLimArray);
    end
    hx=get(gca,'XLabel');
    set(hx,'Units','data');
    pos=get(hx,'Position');
    y=pos(2);
    for i=1:length(xLabels)
        if(strcmp(taskName,'MIDGraph') || strcmp(taskName,'MIDGraphSelect'))
            t(i)=text(2*i-1,y+.02,xLabels{i},'fontSize',labelFont,'Interpreter','default');
        else
            t(i)=text(i,y+.02,xLabels{i},'fontSize',labelFont,'Interpreter','default');
        end
    end
    set(t,'Rotation',90,'HorizontalAlignment','right');
    saveas(gcf,outputFile)
end