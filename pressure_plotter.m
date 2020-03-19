%%%%%% Inputting Date Range %%%%%%%

% start_year = 2019; %year
% start_month = 10; %month
% start_day = 22; %day
% start_hour = 8; %24 hour format
% start_minute = 00; %minute
% 
% end_year = 2019; %year
% end_month = 10; %month
% end_day = 22; %day
% end_hour = 13; %24 hour format
% end_minute = 45; %minute
% 
% 
% start_time= datetime(start_year,start_month,start_day,start_hour,start_minute,0);
% end_time = datetime(end_year,end_month,end_day,end_hour,end_minute,0);
% 
% start_date = datetime(start_year,start_month,start_day);
% end_date = datetime(end_year,end_month,end_day);


%%%%%% Going Back Some Number of Hours From Now %%%%%%%
end_time = datetime('now');
start_time= end_time - hours(30);

start_date = datetime(start_time.Year,start_time.Month,start_time.Day);
end_date = datetime(end_time.Year,end_time.Month,end_time.Day);

pressures = [];
times = [];
currdate = start_date;
index = 0;

while currdate <= end_date
    filename = strcat('Z:\Strontium Pressure Logs\',datestr(currdate,'yyyy-mmm'),'\',datestr(currdate,'yyyy-mmm-dd'),'.csv');
    disp(['Loading: ',datestr(currdate,'yyyy-mmm-dd')])
%     filename = strcat(datestr(currdate,'yyyy-mmmm-dd'),'.csv');
%     these_pressures = readmatrix(filename,'Range','A:C'); ONLY FOR 2019A
%     OR LATER
    try
        file_data = csvread(filename);

        these_pressures = file_data(:,1:3);
        pressures = [pressures;these_pressures];

    %     these_times = readmatrix(filename,'Range','D:D')+index; ONLY FOR
    %     2019A OR LATER
        these_times = file_data(:,4)+index;
        times = [times;these_times];
        clear file_data; %get rid of the huge data file
    catch
        message = strcat('No data found for',datestr(currdate));
        warning(message);
    end
    index = index+24;
    currdate = currdate+1;
end
%now to adjust the time range. Start point should be the start date plus
%the number of hours 
initial_t = start_time.Hour + start_time.Minute/60;
final_t = (index-24) + end_time.Hour + end_time.Minute/60;
str = strcat(datestr(start_date),' to ',datestr(end_date));
figure(2);
clf;
subplot(3,1,1);
scatter(times,pressures(:,1),'k.');
xlim([initial_t,final_t]);
ylabel('Middle Section, [Torr]','fontsize',18);
xlabel('Time, 24 Hr.','fontsize',18);
set(gca, 'YScale', 'log')
annotation('textbox',[.6 .7 .3 .3],'String',str,'FitBoxToText','on');
subplot(3,1,2);
scatter(times,pressures(:,2),'r.');
xlim([initial_t,final_t]);
ylabel('Oven Pressure, [Torr]','fontsize',18);
xlabel('Time, 24 Hr.','fontsize',18);
set(gca, 'YScale', 'log')
subplot(3,1,3);
scatter(times,pressures(:,3),'b.');
xlim([initial_t,final_t]);
ylabel('Main Chamber, [Torr]','fontsize',18);
xlabel('Time, 24 Hr.','fontsize',18);
set(gca, 'YScale', 'log')

%middle section pressures vs oven pressures
% figure(3)
% scatter(pressures(:,2),pressures(:,1),50,'b','filled')
% xlabel('Oven Pressure, [Torr]','fontsize',18);
% ylabel('Middle Pressure, [Torr]','fontsize',18);



