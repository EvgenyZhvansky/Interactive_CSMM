global continue_processing;
continue_processing=true;
selected_regions=[-1]; %select regions to visualize; -1 -- for all regions
store_data=false; %true - turns on data storing, false - turns off

[FileDat, PathDat]=uigetfile('cd/*; *','Open DATA');
if FileDat
    FileName=FileDat;
    Path=PathDat;
end
filename=[Path FileName];
load(filename); %load mat file


regions_id=[];
for i=1:length(selected_regions)
    regions_id=[regions_id;find(data.R'==selected_regions(i))];
end
if selected_regions==-1 || isempty(regions_id)
    regions_id=1:length(data.R');
end
x_coords=data.X(regions_id)';
y_coords=data.Y(regions_id)';
spectra=cell(length(regions_id),1);

for i=1:length(regions_id)
    spectra{i}=data.peaks{regions_id(i)};
end

min_pixx=min(x_coords);
max_pixx=max(x_coords);
min_pixy=min(y_coords);
max_pixy=max(y_coords);
sz=[max_pixy-min_pixy+1, max_pixx-min_pixx+1];

max_size_of_image=500; % max size for resizing visualized images
if max(sz)<max_size_of_image
    rsz=ceil(max_size_of_image/max(sz));
else
    rsz=1; % scale factor for resize image
end

x_coords_img=x_coords-min_pixx+1;
y_coords_img=y_coords-min_pixy+1;

zone_labels=0*x_coords;

img=zeros(sz);
% set(groot, 'defaultFigureWindowState', 'maximized');
figure(1);
fig=gcf;



p = uipanel(fig,'Position',[0 0 0.2 1]);
pfig = uipanel(fig,'Position',[0.2 0 0.8 1]);


cexit = uicontrol(p, 'Style', 'pushbutton', 'Units','normalized','Position', [0.073 0.025 0.073*10 0.05]);
cexit.Callback = @exitPushed;
cexit.String='Exit';

c30 = uicontrol(p, 'Style', 'text', 'Units','normalized','Position', [0.573 0.025*5 0.4 0.05]);
c30.String = 'dpi';

c3 = uicontrol(p, 'Style', 'popupmenu', 'Units','normalized','Position', [0.073 0.025*5 0.5 0.05]);
c3.String = {'300','600'};

c20 = uicontrol(p, 'Style', 'text', 'Units','normalized','Position', [0.073*3 0.025*7 0.073*4 0.05]);
c20.String = 'Save';
c2 = uicontrol(p, 'Style', 'checkbox', 'Units','normalized','Position', [0.073 0.025*7 0.073*2 0.05]);
c2.Value= store_data;

c = uicontrol(p, 'Style', 'edit', 'Units','normalized','Position', [0.073 0.025*11 0.073*11 0.05]);
c.String = '1';
c0 = uicontrol(p, 'Style', 'text', 'Units','normalized','Position', [0.073 0.025*13 0.073*10 0.03]);
c0.String = 'annotation';


b1 = uicontrol(p, 'Style', 'edit', 'Units','normalized','Position', [0.073 0.025*17 0.073*10 0.05]);
b1.String = '1';
b10 = uicontrol(p, 'Style', 'text', 'Units','normalized','Position', [0.073 0.025*19 0.073*10 0.05]);
b10.String = 'm/z binning';


masslow = uicontrol(p, 'Style', 'edit', 'Units','normalized','Position', [0.073 0.025*21 0.073*10 0.05]);
masslow.String = '500';
masslow0 = uicontrol(p, 'Style', 'text', 'Units','normalized','Position', [0.073 0.025*23 0.073*10 0.05]);
masslow0.String = 'low m/z';

masshigh = uicontrol(p, 'Style', 'edit', 'Units','normalized','Position', [0.073 0.025*25 0.073*10 0.05]);
masshigh.String = '1000';
masshigh0 = uicontrol(p, 'Style', 'text', 'Units','normalized','Position', [0.073 0.025*27 0.073*10 0.05]);
masshigh0.String = 'high m/z';

h1=subplot(2,2,1,'Parent',pfig);
h2=subplot(2,2,2,'Parent',pfig);
h3=subplot(2,2,3,'Parent',pfig);
h4=subplot(2,2,4,'Parent',pfig);


imshow(imresize(img,sz*rsz, 'nearest'),'Parent',h1);



regions=data.R(regions_id)';
k=1;
subdir_name=FileName(1:end-4);
[~,~,~]=mkdir('../output_files');
[~,~,~]=mkdir(Path,subdir_name);
[~,~,~]=mkdir([Path,'/',subdir_name],'mat_files');
[~,~,~]=mkdir([Path,'/',subdir_name],'figure_maps');
[~,~,~]=mkdir([Path,'/',subdir_name],'png_maps');
while continue_processing
    figure(fig);
    axes(h1);
    [X, Y]=graphical_input(1);
    
    if isempty(X)
        return;
    end
    
    if ~isempty(find(ismember(h1, gca))) && X/rsz<=sz(2) && Y/rsz<=sz(1) && X>=0 && Y>=0
        bin_step=str2double(b1.String);
        lowm=str2double(masslow.String); % low m/z
        highm=str2double(masshigh.String); % high m/z
        if bin_step<=0
            bin_step=1;
            b1.String='1';
        end
        n=1/bin_step;
        if lowm<0
            lowm=0;
            masslow.String=0;
        end
        if highm<=lowm
            highm=lowm+str2double(b1.String)+1;
            masshigh.String=highm;
        end
        low=lowm*n+1; % low mass index
        high=highm*n; % high mass index
        
        x=round(X/rsz)+min_pixx-1;
        y=round(Y/rsz)+min_pixy-1;
        if x>max_pixx x=max_pixx; end
        if y>max_pixy y=max_pixy; end
        [~,m1]=min(abs(x_coords-x));
        idx=find(x_coords==x_coords(m1));
        [~,m1]=min(abs(y_coords(idx)-y));
        j=find(y_coords(idx)==y_coords(idx(m1)));
        if isempty(j)
            j=size(x_coords,1);
        else
            j=idx(j);
        end
        reg=regions(j);
        spectr1=mat_peaks2spectr(spectra{j}, low, high, n);
        spectr1=spectr1/sqrt(spectr1*spectr1');
        plot(linspace(low/n, high/n, high-low+1),spectr1*100/max(spectr1),'Parent',h4);
        title(h4, sprintf('Selected spectrum\n basepeak intensity = %d,a.u.',round(max(mat_peaks2spectr(spectra{j}, low, high, n)))));
        xlabel(h4,'m/z'); ylabel(h4,'intensity, a.u.')
        pos4=get(h4,'Position');
        
        for i=1:size(x_coords,1)
            spectr2=mat_peaks2spectr(spectra{i}, low, high, n);
            img(y_coords_img(i),x_coords_img(i))=spectr1*spectr2'/sqrt(spectr2*spectr2');
        end
        img(isnan(img))=0;
        
        % cosine map of MS imaging
        imshow(imresize(img,sz*rsz, 'nearest'),'Parent',h1);
        hold(h1, 'on');
        line([0,sz(2)*rsz],[Y, Y], 'Color','black','Parent',h1);
        line([X, X],[0,sz(1)*rsz], 'Color','black','Parent',h1);
        hold(h1, 'off');
        title(h1,sprintf('CSMM, X=%d, Y=%d',x,y));
        colormap(h1,jet);
        colorbar(h1);
        pos1=get(h1,'Position');
        
        % median filtering
        img_filtered=median2D(img);
        imshow(imresize(img_filtered,sz*rsz, 'nearest'),'Parent',h2);
        hold(h2, 'on');
        line([0,sz(2)*rsz],[Y, Y], 'Color','black','Parent',h2);
        line([X, X],[0,sz(1)*rsz], 'Color','black','Parent',h2);
        hold(h2, 'off');
        title(h2,'Median smoothing');
        colormap(h2,jet);
        pos2=get(h2,'Position');
        
        %borders detection in median-filtered image
        pow=4;
        img_div=div_simple(img_filtered, pow);
        img_div4show=imresize(1-img_div,sz*rsz, 'nearest');
        img_div4show=-log2(img_div4show).*img_div4show;
        img_div4show(isnan(img_div4show))=0;
        imshow(1-img_div4show/max(img_div4show(:)),'Parent',h3);
        hold(h3, 'on');
        line([0,sz(2)*rsz],[Y, Y], 'Color','black','Parent',h3);
        line([X, X],[0,sz(1)*rsz], 'Color','black','Parent',h3);
        hold(h3, 'off');
        title(h3,'Borders');
        colorbar(h3,'Ticks',0:0.1:1,'TickLabels',{'1','0.9','0.8','0.7','0.6','0.5','0.4','0.3','0.2','0.1','0'},'location','westoutside');
        pos3=get(h3,'Position');
        
        % save data and figures
        if c2.Value
            drawnow;
            if strcmp(fig.WindowState,'maximized')
                pos = get(fig, 'Position');
                set(fig,'Position', [0 41 pos(3) pos(4)]);
            end
            dot=struct;
            dot.xcoord=x;
            dot.ycoord=y;
            dot.region=reg;
            dot.spectrum=spectra{j};
            dot.cosine_map=img;
            
            dt=datestr(now,'yyyy_mm_dd_HH_MM_SS');
            base_file_name=sprintf('%d_%d_%d_%s_%s',k,x,y, subdir_name,dt);
            fh=fopen([Path,'/',subdir_name,'/zones_and_filenames.txt'],'a');
            fprintf(fh,'%s\t%d\t%d\t%s\r\n', c.String,x,y,base_file_name);
            fclose(fh);
            fig.PaperUnits = 'inches';
            pos = get(gcf, 'Position');
            fig.PaperPosition = [0 0 8.3 pos(4)/pos(3)*8.3];
            
            set(h1, 'Position', pos1);set(h2, 'Position', pos2);set(h3, 'Position', pos3);set(h4, 'Position', pos4);
            print(sprintf('%s/%s/png_maps/%s.png',Path,subdir_name,base_file_name),'-dpng',sprintf('-r%s',c3.String{c3.Value}));
            save(sprintf('%s/%s/mat_files/%s.mat',Path,subdir_name,base_file_name),'dot','-v7');
            savefig(fig, sprintf('%s/%s/figure_maps/%s.fig',Path,subdir_name,base_file_name));
            
            k=k+1;
        end
        
    end
end


function plotButtonPushed(src,event,x,y,subdir_name,Path,c)


dt=datestr(now,'yyyy_mm_dd_HH_MM_SS');
base_file_name=sprintf('%d_%d_%d_%s_%s',x,y, subdir_name,dt);
fh=fopen([Path,'/',subdir_name,'/zones_and_filenames.txt'],'a');
fprintf(fh,'%s\t%d\t%d\t%s\r\n', c.String,x,y,base_file_name);
fclose(fh);

end

function exitPushed(src,event)
global continue_processing;
continue_processing=false;
pause(0.01);
import java.awt.Robot;
import java.awt.event.*;
mouse = Robot;
screenSize = get(0, 'screensize');
pos = get(gcf, 'Position');
mouse.mouseMove(pos(1)+25,screenSize(4)-pos(2)-25);
mouse.mousePress(InputEvent.BUTTON3_MASK);
mouse.mouseRelease(InputEvent.BUTTON3_MASK);
end
