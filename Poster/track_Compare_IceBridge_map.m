clc;clear;
close all;
%% Read data
D = importdata('unified-sea-ice-thickness-cdr-1947-2012/IceBridge_summaries_2009_2011_v1.txt');
tmask_12 = GetNcVar('/mnt/storage0/xhu/CREG012-I/mask/CREG12_mask_v34.nc','tmask',[0 0 0 0],[1632 2400 1 1]);  % surface land mask
[row, col] = size(D.data);

%% Find same campaign
campaign_Name = cell(1, col); % save different names in the data
campaign_Name{1} = D.textdata{2, 2};
campaign_Index = 1; % save the start index of different campaign in campaign_name variable
campaign_Year = D.data(1, 2);
categary_Index = 1; % save the index of categaries, e.g. 1, 2, 3, 4, ...
for i = 3: (row + 1)
    if(~strcmp(campaign_Name{categary_Index}, D.textdata{i, 2}))
        categary_Index = categary_Index + 1;
        campaign_Name{categary_Index} = D.textdata{i, 2};
        campaign_Index = [campaign_Index, i - 1];
        campaign_Year = [campaign_Year, D.data(i-1, 2)];
    end
end
campaign_Index = [campaign_Index, row + 1];

% remove the empty cell in campaign_Name
id = cellfun('length', campaign_Name);
campaign_Name(id == 0) = [];

%% Extrct numerical data
lat = D.data(:, 7);
lon = D.data(:, 8);
Yday = D.data(:, 3);
Avg_ic_with_sn = D.data(:, 23);

%% Plot track
[~, length] = size(campaign_Index);
for i = 2
    tic;
    if(campaign_Year(i) < 2003 || campaign_Year(i) > 2010)
        continue;
    end
    figure;
    %set(gcf, 'Position', [560 524 700 300]);
    % Extrct sub part of lat and lon
    lon_Temp = lon(campaign_Index(i): (campaign_Index(i + 1) - 1));
    lat_Temp = lat(campaign_Index(i): (campaign_Index(i + 1) - 1));
    % Calculate the distance of each separate part of the track
    distance_X_Separate = m_lldist(lon_Temp, lat_Temp);
    % Calculate the distance from the departure place
    distance_X = zeros(1, numel(lat_Temp));
    for j = 2: numel(lat_Temp)
       for k = 1: j-1
          distance_X(j) = distance_X(j) + distance_X_Separate(k); 
       end
    end
    %% Line plot 
    % subplot(211);
    x = 1: (campaign_Index(i + 1) - campaign_Index(i));
    track_Num = numel(x); space = round(track_Num / 7); % I don't plot all points on map, wo I select some of them
    track_Ice = Avg_ic_with_sn(campaign_Index(i) : (campaign_Index(i + 1) - 1)); % data from observation
%     p1 = plot(distance_X, track_Ice', '-', 'LineWidth', 2,'Color', [0 0 0] );
%     m_proj('stereographic','latitude',80,'longtitude',-100, 'radius',15,'rect', 'on'); %map1
    m_proj('stereographic','latitude',85,'longtitude',-110, 'radius',20,'rect', 'on'); %map2
%     m_proj('lambert','long',[-150 0],'lat',[70 90]);

%     %% ANHA12
%     % Read Lon and Lat
%     srcP='/mnt/storage0/xhu/CREG012-EXH003/'; % 12th
%     ncfile=[srcP,'CREG012-EXH003_y2003m01d05_icemod.nc']; % 12th
%     lon_12=GetNcVar(ncfile,'nav_lon',[0 0],[1632 2400]);
%     lat_12=GetNcVar(ncfile,'nav_lat',[0 0],[1632 2400]);
%     track_ANHA12 = zeros(size(x)); % data from ANHA4
%     date_All = cell(1, (campaign_Index(i + 1) - campaign_Index(i)));
%     ANHA12_range_down = zeros(size(x));
%     ANHA12_range_up = zeros(size(x));
%     for j = 1: (campaign_Index(i + 1) - campaign_Index(i))
%         % Calculate the data
%         yearCounter = campaign_Year(i);
%         timeCounter = 5 * round(Yday(campaign_Index(i) + j - 1) / 5);
%         date = num2date(yearCounter, timeCounter);
%         date_All{1, j} = date;
%         % Read NC File
%         srcP='/mnt/storage0/xhu/CREG012-EXH003/'; % 12th
%         ncfile=[srcP,'CREG012-EXH003_y',date,'_icemod.nc']; % 12th
%         NY=2400; NX=1632; % dimension of the whole model domain
%         subII=1:1632; subJJ=1:2400;
%         % Read ice Thickness
%         iceC=GetNcVar(ncfile,'iicethic',[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]);
%         iceC(tmask_12 == 0) = NaN;
%         % Find neighbour grid points
%         [result,index]=sort((lat_12(:) - lat_Temp(j)).*(lat_12(:) - lat_Temp(j)) + (lon_12(:) - lon_Temp(j)).*(lon_12(:) - lon_Temp(j)));
%         inverseDistance = zeros(1,9);
%         for k = 1:9
%             if(~isnan(iceC(index(k))))
%                 inverseDistance(1,k) = 1 / sum((m_ll2xy(lon_Temp(j), lat_Temp(j)) - m_ll2xy(lon_12(index(k)), lat_12(index(k)))) .^ 2);
%             else
%                 inverseDistance(1,k) = 0;
%             end
%         end
%         sum_Distance = sum(inverseDistance);
%         ANHA12_range_down(j) = 10;
%         ANHA12_range_up(j) = 0;
%         for k = 1:9
%             if(inverseDistance(1,k) ~= 0)
%                 track_ANHA12(j) = track_ANHA12(j) + iceC(index(k)) * inverseDistance(1, k) / sum_Distance;
%             end
%         end
%         for k = 1:9
%            % Calculate the up and down range of the model output
%             if(iceC(index(k)) < ANHA12_range_down(j))
%                ANHA12_range_down(j) = iceC(index(k));
%             end
%             if(iceC(index(k)) > ANHA12_range_up(j))
%                ANHA12_range_up(j) = iceC(index(k));
%             end 
%         end
%     end
%     hold on;
%     p2 = plot(distance_X, track_ANHA12, '-r', 'LineWidth', 2);
%     plot(distance_X, ANHA12_range_down, '--r', 'LineWidth', 0.7);
%     plot(distance_X, ANHA12_range_up, '--r', 'LineWidth', 0.7);
%     grid on;
%     set(gca,'fontweight','bold','fontsize',7,'fontname','Nimbus Sans L');
%     clear title xlabel ylabel;
%     xlabel('Distance /km');
%     ylabel('Thickness /m');
%     % title
%     title = title(['FILE: IceBridge_summaries_2009_2011_v1 TRACK: ', campaign_Name{i}, ' ', num2str(campaign_Year(i))], 'fontweight','bold','fontsize', 12,'fontname','Nimbus Sans L');
%     set(title,'Interpreter','none');
%     xLimit = get(gca, 'XLim');
%     xLimit_up = round(xLimit(2) / 3.5);
%     set(gca, 'XLim', [0, xLimit(2) + xLimit_up]);
%     legend([p1 p2], 'Observation', 'ANHA12', 'Location', 'NorthEast');
%     % Calculate the position of each points in global coordinate
%     x1 = zeros(1, xLimit(2) + xLimit_up);
%     y1 = zeros(1, xLimit(2) + xLimit_up);
%     YLim_plot = get(gca, 'YLim');
%     disp(['ANHA12 finished ', num2str(i)]);
    %% Map plot
    % subplot(212);
    % Mean track data index
    mean_Index = round((campaign_Index(i + 1) - campaign_Index(i)) / 2);
    min_Lon = find(lon_Temp == min(lon_Temp));
    min_Lat = find(lat_Temp == min(lat_Temp));
    max_Lon = find(lon_Temp == max(lon_Temp));
    max_Lat = find(lat_Temp == max(lat_Temp));
    if(max(lon_Temp) - min(lon_Temp) > 100 || max(lat_Temp) - min(lat_Temp) > 100)
        radius = 30;
    elseif(max(lon_Temp) - min(lon_Temp) < 13 && max(lat_Temp) - min(lat_Temp) < 13)
        radius = 10;
    else
        radius = max(max(lon_Temp) - min(lon_Temp), max(lat_Temp) - min(lat_Temp)) / 3;
    end
    % m_proj('albers equal-area','longitudes',[lon_Temp(min_Lon) - 10, lon_Temp(max_Lon) + 10], ...
    %    'latitudes',[lat_Temp(min_Lat) - 5, lat_Temp(max_Lat) + 5],'rect','on');
%     m_proj('stereographic','latitude',(max(lat_Temp) + min(lat_Temp))/2,'longtitude', (max(lon_Temp) + min(lon_Temp))/2,'radius',radius);
    m_grid;
    disp(['grid finish ', num2str(i)]);
    m_gshhs_i('patch',[0 0 0],'linestyle','none');% plot map grid
    m_nolakes;
    disp(['gshhs finish ', num2str(i)]);
    color_Temp = rand(1,3);
%     if(radius == 10)
%         for j = 1: (campaign_Index(i + 1) - campaign_Index(i))
%             m_line(lon_Temp(j), lat_Temp(j), 'Color', 'g', 'LineStyle', '*', 'LineWidth', 5);
%         end
%     else
%         m_line(lon_Temp, lat_Temp, 'linewi',1.7, 'Color', 'g');
%     end
    for j = 1: (campaign_Index(i + 1) - campaign_Index(i))
        m_line(lon_Temp(j), lat_Temp(j), 'Color', 'g', 'LineStyle', '*', 'LineWidth', 4);
    end
    for j = 1: (campaign_Index(i + 1) - campaign_Index(i))
        if(j == 1 || j == (campaign_Index(i + 1) - campaign_Index(i)))
            [x, y] = m_ll2xy(lon_Temp(j), lat_Temp(j));
            text(x, y, num2str(j), 'Color', 'r', 'FontSize', 7, 'fontweight','bold', 'fontname','Nimbus Sans L');
        end
        if(rem(j, space) == 0)
            [x, y] = m_ll2xy(lon_Temp(j), lat_Temp(j));
            text(x, y, num2str(j), 'Color', 'r', 'FontSize', 7, 'fontweight','bold', 'fontname','Nimbus Sans L');
        end
%         hleg1 = text(0.13,(0.14 - room*j), [num2str(j), ' (Lat: ', num2str(lat_Temp(j)), ', Lon: ', num2str(lon_Temp(j)), ') ', date_All{1, j}]...
%             , 'Color', 'k', 'FontSize', 4, 'fontweight','bold', 'fontname','Nimbus Sans L');
    end
    set(gca,'fontweight','b','fontsize',13,'fontname','Nimbus Sans L');
    %% Change the font and size of the label in maps
    hxlabel=findobj(gca,'tag','m_grid_xticklabel'); set(hxlabel,'fontweight','b','fontsize',8,'fontname','Nimbus Sans L');
    hylabel=findobj(gca,'tag','m_grid_yticklabels'); set(hylabel,'fontweight','b','fontsize',8,'fontname','Nimbus Sans L','rotation',0');
    % Delete lontitude line according to the number of the lontitude
    % available
    delete(hylabel(1: numel(hylabel)));
    delete(hxlabel(1: numel(hxlabel)));
    %    text_Num = round((campaign_Index(i + 1) - campaign_Index(i)) / 2);
    %    [x, y] = m_ll2xy(lon_Temp(text_Num), lat_Temp(text_Num));
    %    text(x, y, num2str(i), 'Color', 'r', 'FontSize', 6, 'fontweight','bold', 'fontname','Nimbus Sans L');
    %     hleg1 = text(0.7,(0.6 - room*i), [num2str(i), ' ', campaign_Name{i}, ' ', num2str(campaign_Year(i))], 'Color', color_Temp, 'FontSize', 8, 'fontweight','bold', 'fontname','Nimbus Sans L');
    %     set(hleg1,'Interpreter','none');
    %    legend = m_legend('a');
    %    set(legend, 'AmbientLightColor', 'b');
%     hold on;
%     hax = axes();
%     set(hax, 'Color', 'none');
%     axis off;
%     set(gca,'Xlim',[0 1]);
%     set(gca,'Ylim',[0 1]);
%     set(gcf, 'currentAxes', hax);
% 
%     %% Annotation at the side of the map
%     long = (campaign_Index(i + 1) - campaign_Index(i));
%     room = 2.0 / long;
%     for j = 1: long
%         if(j < long/4)
%             text(-0.08,(0.5 - room*(j)), [num2str(j), ' (Lat: ', num2str(lat_Temp(j)), ', Lon: ', num2str(lon_Temp(j)), ') ', date_All{1, j}]...
%                 , 'Color', 'k', 'FontSize', 3, 'fontweight','bold', 'fontname','Nimbus Sans L');
%         elseif(j < long/2 && j >= long/4)
%             text(0.07,(0.5 - room*(round(j - long / 4))), [num2str(j), ' (Lat: ', num2str(lat_Temp(j)), ', Lon: ', num2str(lon_Temp(j)), ') ', date_All{1, j}]...
%                 , 'Color', 'k', 'FontSize', 3, 'fontweight','bold', 'fontname','Nimbus Sans L');
%         elseif(j < long*3/4 && j >= long/2)
%             text(0.8,(0.5 - room*(round(j - long / 2))), [num2str(j), ' (Lat: ', num2str(lat_Temp(j)), ', Lon: ', num2str(lon_Temp(j)), ') ', date_All{1, j}]...
%                 , 'Color', 'k', 'FontSize', 3, 'fontweight','bold', 'fontname','Nimbus Sans L');
%         else
%             text(0.95,(0.5 - room*(round(j - long*3/4))), [num2str(j), ' (Lat: ', num2str(lat_Temp(j)), ', Lon: ', num2str(lon_Temp(j)), ') ', date_All{1, j}]...
%                 , 'Color', 'k', 'FontSize', 3, 'fontweight','bold', 'fontname','Nimbus Sans L');
%         end
%     end
    toc;
    % set(gcf,'paperPositionMode','auto'); % print the figure with the same size in matlab
     print(gcf, '-dpng' ,'-r300',['IceBridge_summaries_2009_2011_v1_', campaign_Name{i}, '_map.png']);
end
% 
% % for i = 1:length-1
% %     lon_Temp = lon(campaign_Index(i): (campaign_Index(i + 1) - 1));
% %     lat_Temp = lat(campaign_Index(i): (campaign_Index(i + 1) - 1));
% %     text_Num = round((campaign_Index(i + 1) - campaign_Index(i)) / 2);
% %     [x, y] = m_ll2xy(lon_Temp(text_Num), lat_Temp(text_Num));
% %     text(x, y, num2str(i), 'Color', 'r', 'FontSize', 6, 'fontweight','bold', 'fontname','Nimbus Sans L');
% % end
% 

