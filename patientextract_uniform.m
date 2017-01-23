function data = patientextract_uniform(project, begslice, endslice, L, x, ...
    N, spacing, pts, maski, show)
% Function created on 11/24/15 based on phantomextract_uniform.
% Additional input argument pts = points to calculate per slice. pts should
% be at least 2 (I think)

% Constants:
linespecs = {'r','b','k','g','y','c','m'};

sliceinc = abs(project.images(2).location - project.images(1).location);
psize = project.pixel_size;
n = length(project.images);

% Convert L (mm) to L (pixels):
L = L/psize;
% Convert spacing (mm) to spacing (pixels):
spacing = spacing/psize;

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
    hy = ylabel(hax,'Initiating...','FontSize',12);
    drawnow
end

% p is the sample # in the output data structure
p = 0;

% preallocate data structure
C = cell((endslice-begslice+1)*pts,1);
data = struct('array',C,'xval',C,'spacelat',C,'spaceslice',C,'slice',C,...
    'angle',C,'centroid',C,'point',C);

%h_w = waitbar(0,'Extracting features...');
fprintf('Extracting features...\n');
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
    
    % Get angle vector, extract feature for each angle in current slice
    angle = linspace(0,2*pi,pts+1);
    angle(end) = [];
    
    % if idx is odd, then shift angle points by half an angle increment
    if mod(idx,2) ~= 0
        shift = (angle(2) - angle(1))/2;
        angle = angle + shift;
    end
    
    for a = 1:length(angle)
        
        p = p + 1; % next sample in output data structure
        
        ray = [centroid(1),centroid(2); ...
            centroid(1)+100*cos(angle(a)), centroid(2)-100*sin(angle(a))];

        [x0,y0]=intersections(ray(:,1),ray(:,2),B(:,2),B(:,1));

        if show
            set(hI,'CData',im)
            set(hT,'string',['Slice #: ', num2str(i),...
                            ', lateral index: --',...
                            ', slice index: --'])
            set(hx,'string',['Angle: ', num2str(angle(a)*180/pi), ' degrees'])
            set(hy,'string',['Current Slice Shown: ', num2str(i)])
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

        array = zeros(x,x,N);
        spacelat = zeros(x,1);
        spaceslice = zeros(x,1);

        for k = 1:x % lateral index

            lati = k-(x+1)/2; % lateral index (eg -1,0,1 for odd
                                              % or -1.5, -0.5, 0.5, 1.5 even)
            spacelat(k) = lati*spacing*psize;
            % Need x,y starting points of line:
            x1 = x0-L/2*cos(angle(a));
            y1 = y0+L/2*sin(angle(a));
            xk = x1 - lati*spacing*cos(angle(a)+pi/2);
            yk = y1 + lati*spacing*sin(angle(a)+pi/2);
            xkend = xk + L*cos(angle(a));
            ykend = yk - L*sin(angle(a));

            for j = 1:x % slice index
                % Get slices for interpolation

                slicei = j-(x+1)/2; % slice index (eg -1, 0, 1)
                spaceslice(j) = slicei*spacing*psize;

                loc = slicei*spacing*psize; % mm from current slice

                sliceabove = i+floor(loc/sliceinc);
                slicebelow = i+ceil(loc/sliceinc);

                weight = mod(loc/sliceinc,1); % normalized distance from sliceabove

                if sliceabove == slicebelow
                    slicebelow = sliceabove + 1;
                    weight = 0;
                end

                if sliceabove < 1 || slicebelow > n % slice is out of range
                    line = nan(N,1);
                else % get image profileline data from both slices, then take
                     % weighted average

                    % ABOVE
                    Iabove = project.images(sliceabove).image;
                    lineabove = improfile(Iabove,[xk xkend],[yk ykend],N);
                    if show
                        set(hI,'CData',Iabove)
                        delete(findobj(hax,'tag','deleteme2'))
                        set(hT,'string',['Slice #: ', num2str(i),...
                            ', lateral index: ', num2str(lati),...
                            ', slice index: ', num2str(slicei), ' above'])
                        set(hy,'string',['Current Slice Shown: ', num2str(sliceabove)])
                        plot(hax,[xk xkend],[yk ykend],...
                            linespecs{randi([1 length(linespecs)])},'tag','deleteme2')
                        pause(0.2)
                        if strcmp(get(hfig,'tag'),'closeme')
                            show = false;
                            delete(hfig)
                        end
                    end

                    % BELOW
                    Ibelow = project.images(slicebelow).image;
                    linebelow = improfile(Ibelow,[xk xkend],[yk ykend],N);
                    if show
                        set(hI,'CData',Ibelow)
                        delete(findobj(hax,'tag','deleteme2'))
                        set(hT,'string',['Slice #: ', num2str(i),...
                            ', lateral index: ', num2str(lati),...
                            ', slice index: ', num2str(slicei), ' below'])
                        set(hy,'string',['Current Slice Shown: ', num2str(slicebelow)])
                        plot(hax,[xk xkend],[yk ykend],...
                            linespecs{randi([1 length(linespecs)])},'tag','deleteme2')
                        pause(0.2)
                        if strcmp(get(hfig,'tag'),'closeme')
                            show = false;
                            delete(hfig)
                        end
                    end

                    line = (1-weight)*lineabove + weight*linebelow;

                end
                array(j,k,:) = line;
            end
        end
        
        data(p).array = array;
        data(p).xval = linspace(0,L*psize,size(array,3));
        data(p).spacelat = spacelat;
        data(p).spaceslice = spaceslice;
        data(p).slice = i;
        data(p).angle = angle(a);
        data(p).centroid = centroid;
        data(p).point = [x0,y0];
    
    end
    
    %waitbar(idx/((endslice-begslice)+1), h_w);
    
end

%delete(h_w)
close all