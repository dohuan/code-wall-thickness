function data = phantomextract(project, begslice, endslice, L, x, maski, show, h_d)
% See lab notes 3/25/15 for a description of this function
% Assumes that begslice is the slice location with "initialthickness" and
% that the change in thickness varies toward end slice according to the
% rate "slope" below.
% NOTE: assumes that pixel_size >> slice_increment, therefore uses
% pixel_size to determine spacing between profile lines in an array
% show: boolean, show results while running?

% Constants:
initialthickness = 3; % mm
slope = -0.0440107; %mm/mm
linespecs = {'r','b','k','g','y','c','m'};

sliceinc = abs(project.images(2).location - project.images(1).location);
psize = project.pixel_size;
n = length(project.images);

% Convert L (mm) to L (pixels):
L = L/psize;

% start at lower slice index
if begslice > endslice % switch
    temp = begslice;
    begslice = endslice;
    endslice = temp;
    clear temp
end

if show
    hfig = figure;
    set(hfig,'CloseRequestFcn','set(gcf,''tag'',''closeme'')')
    hI = imshow(project.images(1).image,[project.minHU,project.maxHU]);
    hax = get(hI,'Parent');
    set(hax,'NextPlot','add')
    hT = title(hax,'Initiating...','FontSize',14);
    hx = xlabel(hax,'Initiating...','FontSize',12);
    drawnow
end

for idx = 1:((endslice-begslice)+1)
    
    i = idx+begslice-1; % current slice index
    
    im = project.images(i).image;
    mask = project.masks(maski).data{i};
    
    stats = regionprops(mask,'centroid');
    try
        centroid = stats.Centroid;
    catch ME
        if strcmp(ME.identifier,'MATLAB:TooManyOutputsDueToMissingBraces')
            error('I think we encountered a slice with no mask data.')
        end
    end
    B = bwboundaries(mask);
    B = B{1};
    % NOTE: B(:,2) are x coords (columns), B(:,1) are y coords (rows)
    angle = rand*2*pi;
    
    ray = [centroid(1),centroid(2); ...
        centroid(1)+100*cos(angle), centroid(2)-100*sin(angle)];
    
    [x0,y0]=intersections(ray(:,1),ray(:,2),B(:,2),B(:,1));
    
    if show
        set(hI,'CData',im)
        set(hT,'string',['Slice #: ', num2str(i),...
                        ', lateral index: --',...
                        ', slice index: --'])
        set(hx,'string',['Angle: ', num2str(angle*180/pi), ' degrees'])
        delete(findobj(hax,'tag','deleteme1'))
        delete(findobj(hax,'tag','deleteme2'))
        plot(hax,B(:,2),B(:,1),'tag','deleteme1')
        plot(hax,centroid(1),centroid(2),'r.','tag','deleteme1')
        plot(hax,ray(:,1),ray(:,2),'g','tag','deleteme1')
        plot(hax,x0,y0,'b.','tag','deleteme1')
        pause(1)
        if strcmp(get(hfig,'tag'),'closeme')
            show = false;
            delete(hfig)
        end
    end
        
    % Define number of points to calculate along each line:
    N = ceil(L);
    
    array = zeros(x,x,N);
    spacelat = zeros(x,1);
    spaceslice = zeros(x,1);
    
    for k = 1:x % lateral index

        lati = k-(x+1)/2; % lateral index (eg -1,0,1 for odd
                                          % or -1.5, -0.5, 0.5, 1.5 even)
        spacelat(k) = lati*psize;
        % Need x,y starting points of line:
        x1 = x0-L/2*cos(angle);
        y1 = y0+L/2*sin(angle);
        xk = x1 - lati*cos(angle+pi/2);
        yk = y1 + lati*sin(angle+pi/2);
        xkend = xk + L*cos(angle);
        ykend = yk - L*sin(angle);

        for j = 1:x % slice index                
            slice = i+round(((j-(x+1)/2)*psize)/sliceinc);
            spaceslice(j) = (slice-i)*sliceinc;

            if slice < 1 || slice > n % slice is out of range
                line = nan(N,1);
            else % get image profileline data
                I = project.images(slice).image;
                line = improfile(I,[xk xkend],[yk ykend],N);
                if show
                    set(hI,'CData',I)
                    delete(findobj(hax,'tag','deleteme2'))
                    set(hT,'string',['Slice #: ', num2str(i),...
                        ', lateral index: ', num2str(lati),...
                        ', slice index: ', num2str(slice-i)])
                    plot(hax,[xk xkend],[yk ykend],...
                        linespecs{randi([1 length(linespecs)])},'tag','deleteme2')
                    pause(0.2)
                    if strcmp(get(hfig,'tag'),'closeme')
                        show = false;
                        delete(hfig)
                    end
                end
            end
            array(j,k,:) = line;
        end
    end
        
    data(idx).array = array;
    data(idx).xval = linspace(0,L*psize,size(array,3));
    data(idx).thickness = initialthickness + (idx-1)*sliceinc*slope; % mm
    data(idx).spacelat = spacelat;
    data(idx).spaceslice = spaceslice;
    data(idx).slice = i;
    data(idx).angle = angle;
    data(idx).centroid = centroid;
    data(idx).point = [x0,y0];
    
end

if show && ishandle(hfig)
    set(hfig,'CloseRequestFcn','delete(gcbo)')
end