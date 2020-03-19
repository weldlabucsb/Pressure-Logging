function ig_monitor_v2

COM='COM5';
updatePeriod = 1;


%% Initialize GUI figure and text box
disp('Opening ion gauge monitor');
successfulConnection    = false;

hF = figure    ('Name',         'Ion Gauge Pressures',...
                'MenuBar',      'none',...
                'ToolBar',      'none',...
                'NumberTitle',  'Off',...
                'Resize',       'off',...
                'Color',        'w',...
                'Position',     [500 500 480 160]);
clf;
set(hF,'CloseRequestFcn',@(~,~) ...
    disp([datestr(now,13) ...
    ' Close the GUI using the buttons']));

% Close button
buttSize=[15 15];
buttClose=uicontrol(hF, 'style', 'pushbutton');
buttClose.Position(3)=buttSize(1);
buttClose.Position(4)=buttSize(2);
buttClose.Position(1)=hF.Position(3)-buttSize(1);
buttClose.Position(2)=hF.Position(4)-buttSize(2);
buttClose.CData=imresize(imread(...
    'close.png','BackgroundColor', hF.Color),buttSize);    
buttClose.Callback=@closeITALL;
drawnow;

function closeITALL(~,~)
    if (successfulConnection)
        try
            disp([datestr(now, 13) ' Stopping and closing the timer.']);
            stop(mytimer);
            delete(mytimer);
        catch
            disp([datestr(now, 13) ' Failed to close timer.']);
        end
        try
            disp([datestr(now, 13) ' Disconnecting serial connection.']);
            fclose(s);
            delete(s);
        catch
            disp([datestr(now, 13) ' Failed to disconnect serial connection.']);
        end
    end
    delete(hF);
end

tt = uicontrol ('Style','Text',...
                'Position',[20 20 hF.Position(3)-40 hF.Position(4)-40],...
                'backgroundcolor','w','fontsize',24,...
                'horizontalalignment','left',...
                'FontName','Courier','fontweight','bold');

%% Initialize serial connection
try
    s = establishConnection(COM);
    pause(0.5);
    successfulConnection = true;    
    % Determine number of devices on the XGS-600
    fprintf(s, '#0001');
    out = fscanf(s);
catch
    close;
    disp([datestr(now, 13) ' Failed to establish serial connection.']);
    return;
end

%% Initialize timer
mytimer = timer('Period',        updatePeriod,...
                'ExecutionMode', 'fixedSpacing',...
                'TimerFcn',      @updateValues);    

    function updateValues(~,~)
        fprintf(s, '#000F');
        
        % replace comma separations with newlines
        % remove initial ">"
        out = strip(strrep(fscanf(s), ',', newline),'>');
        out(end)=[];
        
        out2=strsplit(out,newline);
        pressures = out2;
        out2=['HFIG 1 : ' out2{1} ' Torr' newline ...
            'HFIG 2 : ' out2{2} ' Torr' newline ...
            'HFIG 3 : ' out2{3} ' Torr'];
        
        % OPTION: label each pressure
        now_clock = clock;
        to_write = [pressures{1} ',' pressures{2} ',' pressures{3} ',' num2str(24*mod(now,1)) ...
            ',' num2str(now_clock(4)) ',' num2str(now_clock(5)) ',' num2str(now_clock(6)) newline];
        tt.String = out2;
        filename = strcat('Z:\Strontium Pressure Logs\',date,'.csv');
        [fileID,errorMsg] = fopen(filename,'a+');
        assert(fileID>0,['Failed to Access File: ',filename,'.  Reason: ',errorMsg])
        fprintf(fileID,to_write);
        fclose(fileID);
    end

start(mytimer)



end



function s = establishConnection(COM)
    port        = COM;
    baud        = 9600;
    databits    = 8;
    stopbits    = 1;
    parity      = 'none';
    flowcontrol = 'none';
    terminator  = 'CR';
    
    s = serial (                port,...
                'BaudRate',     baud,...
                'Parity',       parity,...
                'StopBits',     stopbits,...
                'DataBits',     databits,...
                'FlowControl',  flowcontrol,...
                'Terminator',   terminator);
    fopen      (s);
    disp       ('Serial connection established.');
end