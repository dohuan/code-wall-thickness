function data = microextract_uniform(Cproject,Mproject,Cmaski,Mmaski,...
    Cbegslice,Cendslice,Mbegslice,L,x,spp,N,spacing,show,h_d)
% Function created on 7/9/15 based on microextract. It is modified in
% order to have uniform spacing for the various profile lines (this value
% is chosen), as opposed to spacing which is based on pixel size and is
% non-uniform. Also, it uses a chosen number of points for the profile
% lines, rather than an automatically chosen value.

% spp (slices per point) used to be called k. I renamed it to ssp due to
% bug where variable k was used in lateral index loop (k = 1:x). 11/10/15
% -Bara

% Assumes that Cbegslice and Mbegslice represent the same axial location,
% AND that both data sets proceed in the same direction axially from
% min(Cbegslice,Cendslice) to max(Cbegslice,Cendslice) (they will be switched
% if Cbegslice is not less than Cendslice).

% Use Csliceinc and Msliceinc to traverse an approximately equal distance
% along each data set.

linespecs = {'r','b','k','g','y','c','m'};

Csliceinc = abs(Cproject.images(2).location - Cproject.images(1).location);
Msliceinc = abs(Mproject.images(2).location - Mproject.images(1).location);

Cpsize = Cproject.pixel_size;
Mpsize = Mproject.pixel_size;
nC = length(Cproject.images);
nM = length(Mproject.images);

% Convert L (mm) to L (pixels):
Lc = L/Cpsize;
Lm = L/Mpsize;
% Convert spacing (mm) to spacing (pixels), only for clinical, since used
% only for feature extraction.
spacing = spacing/Cpsize;

% start at lower slice index
if Cbegslice > Cendslice % switch
    temp = Cbegslice;
    Cbegslice = Cendslice;
    Cendslice = temp;
    clear temp
end

if show
    hfig = figure;
    set(hfig,'CloseRequestFcn','set(gcf,''tag'',''closeme'')')
    haxC = subplot(2,1,1);
    haxM = subplot(2,1,2);
    axes(haxC)
    hIC = imshow(Cproject.images(1).image,[Cproject.minHU,Cproject.maxHU],...
        'parent',haxC);
    hIM = imshow(Mproject.images(1).image,[Mproject.minHU,Mproject.maxHU],...
        'parent',haxM);
    set([haxC,haxM],'NextPlot','add')
    hT = title(haxC,'Initiating...','FontSize',14);
    hy = ylabel(haxC,'Initiating...','FontSize',12);
    hx = xlabel(haxM,'Initiating...','FontSize',12);
    drawnow
end

% Traverse clinical slices one by one, choose one point on each spp slices.
for idx = 1:ceil((Cendslice-Cbegslice+1)/spp)
    
    i = Cbegslice+(idx-1)*spp; % current slice index
    
    % Get data from clinical image first:
    im = Cproject.images(i).image;
    mask = Cproject.masks(Cmaski).data{i};
    
    stats = regionprops(mask,'centroid');
    try
        centroid = stats.Centroid;
    catch ME
        if strcmp(ME.identifier,'MATLAB:TooManyOutputsDueToMissingBraces')
            error('I think we encountered a clinical slice with no mask data.')
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
        set(hIC,'CData',im)
        set(hT,'string',['Slice #: ', num2str(i),...
                        ', lateral index: --',...
                        ', slice index: --'])
        set(hx,'string',['Angle: ', num2str(angle*180/pi), ' degrees'])
        set(hy,'string',['Current Slice Shown: ', num2str(i)])
        delete(findobj(haxC,'tag','deleteme1'))
        delete(findobj(haxC,'tag','deleteme2'))
        plot(haxC,B(:,2),B(:,1),'tag','deleteme1')
        plot(haxC,centroid(1),centroid(2),'r.','tag','deleteme1')
        plot(haxC,ray(:,1),ray(:,2),'g','tag','deleteme1')
        plot(haxC,x0,y0,'b.','tag','deleteme1')
        pause(0.5)
        if strcmp(get(hfig,'tag'),'closeme')
            show = false;
            delete(hfig)
        end
    end
    
    % Define number of points to calculate along each line:
    % N = ceil(Lc);
    % User provided N value.
    
    array = zeros(x,x,N);
    spacelat = zeros(x,1);
    spaceslice = zeros(x,1);
    
    for k = 1:x % lateral index

        lati = k-(x+1)/2; % lateral index (eg -1,0,1 for odd
                                          % or -1.5, -0.5, 0.5, 1.5 even)
        spacelat(k) = lati*spacing*Cpsize;
        % Need x,y starting points of line:
        x1 = x0-Lc/2*cos(angle);
        y1 = y0+Lc/2*sin(angle);
        xk = x1 - lati*spacing*cos(angle+pi/2);
        yk = y1 + lati*spacing*sin(angle+pi/2);
        xkend = xk + Lc*cos(angle);
        ykend = yk - Lc*sin(angle);

        for j = 1:x % slice index       
            % Get slices for interpolation
            
            slicei = j-(x+1)/2; % slice index (eg -1, 0, 1)
            spaceslice(j) = slicei*spacing*Cpsize;
            
            loc = slicei*spacing*Cpsize; % mm from current slice
            
            sliceabove = i+floor(loc/Csliceinc);
            slicebelow = i+ceil(loc/Csliceinc);
            
            weight = mod(loc/Csliceinc,1); % normalized distance from sliceabove
            
            if sliceabove == slicebelow
                slicebelow = sliceabove + 1;
                weight = 0;
            end
            
            if sliceabove < 1 || slicebelow > nC % slice is out of range
                line = nan(N,1);
            else % get image profileline data from both slices, then take
                 % weighted average
                
                % ABOVE                
                Iabove = Cproject.images(sliceabove).image;
                lineabove = improfile(Iabove,[xk xkend],[yk ykend],N);
                
                if show
                    set(hIC,'CData',Iabove)
                    delete(findobj(haxC,'tag','deleteme2'))
                    set(hT,'string',['Slice #: ', num2str(i),...
                        ', lateral index: ', num2str(lati),...
                        ', slice index: ', num2str(slicei), ' above'])
                    set(hy,'string',['Current Slice Shown: ', num2str(sliceabove)])
                    plot(haxC,[xk xkend],[yk ykend],...
                        linespecs{randi([1 length(linespecs)])},'tag','deleteme2')
                    pause(0.2)
                    if strcmp(get(hfig,'tag'),'closeme')
                        show = false;
                        delete(hfig)
                    end
                end
                
                % BELOW      
                Ibelow = Cproject.images(slicebelow).image;
                linebelow = improfile(Ibelow,[xk xkend],[yk ykend],N);
                
                if show
                    set(hIC,'CData',Ibelow)
                    delete(findobj(haxC,'tag','deleteme2'))
                    set(hT,'string',['Slice #: ', num2str(i),...
                        ', lateral index: ', num2str(lati),...
                        ', slice index: ', num2str(slicei), ' below'])
                    set(hy,'string',['Current Slice Shown: ', num2str(slicebelow)])
                    plot(haxC,[xk xkend],[yk ykend],...
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
    
    % NOW, get thickness data from micro image:
    % Find correct slice in micro image
    d = (i-Cbegslice)*Csliceinc; % distance from Cbegslice (mm)
    j = Mbegslice + round(d/Msliceinc); % current micro slice index
    err = (j-Mbegslice)*Msliceinc-d; % deviation from desired distance (mm)
     
    % Get wall thickness data from micro image (j):
    if j < 1 || j > nM
        error('Requesting out-of-range slice from micro image.')
    end
    imM = Mproject.images(j).image;
    maskM = Mproject.masks(Mmaski).data{j};
    
    statsM = regionprops(maskM,'centroid');
    try
        centroidM = statsM.Centroid;
    catch ME
        assignin('base','i',i)
        assignin('base','j',j)
        if strcmp(ME.identifier,'MATLAB:TooManyOutputsDueToMissingBraces')
            error('I think we encountered a micro slice with no mask data.')
        end
    end
    BM = bwboundaries(maskM);
    BM = BM{1};
    % NOTE: BM(:,2) are x coords (columns), BM(:,1) are y coords (rows)
    
    % angle aleady known
    
    rayM = [centroidM(1),centroidM(2); ...
        centroidM(1)+150*cos(angle), centroidM(2)-150*sin(angle)];
    
    [x0M,y0M]=intersections(rayM(:,1),rayM(:,2),BM(:,2),BM(:,1));
    
    % Add 0.75 mm in outward direction to locate pt closer to center of
    % wall
    x0M = x0M + (0.75/Mpsize)*cos(angle);
    y0M = y0M - (0.75/Mpsize)*sin(angle);
    
    % Get profile line across wall boundary, and measure thickness using
    % edge detector. Use 6mm line centered at x0M, y0M.
    len = 6; % can edit this to change length of line
    xM = x0M - (len/2/Mpsize)*cos(angle);
    xMend = x0M + (len/2/Mpsize)*cos(angle);
    yM = y0M + (len/2/Mpsize)*sin(angle);
    yMend = y0M - (len/2/Mpsize)*sin(angle);
    
    wall = improfile(imM,[xM xMend],[yM yMend]);
    xval = linspace(0,len,length(wall));
    try
        [ ~, minmax, ~ ] = AnalyzeEdges(wall);
    catch
        % AnalyzeEdges failed, not sure why
        display('Analyze edges failed, not sure why')
        display(['i = ' num2str(i)])
        display(['j = ' num2str(j)])
        minmax = [];
    end
    pts = find(minmax);
    if length(pts) < 2
        thickness = nan; % less than 2 steps were detected. not sure what to do.
    elseif length(pts) == 2
        thickness = xval(pts(2)) - xval(pts(1));
    else
        thickness = [xval(pts(2)) - xval(pts(1)), 0];
        % 0 indicates additional steps were found, first 2 used
    end
    
    if show
        set(hIM,'CData',imM)
        delete(findobj(haxM,'tag','deleteme'))
        plot(haxM,BM(:,2),BM(:,1),'tag','deleteme')
        plot(haxM,centroidM(1),centroidM(2),'r.','tag','deleteme')
        plot(haxM,rayM(:,1),rayM(:,2),'g','tag','deleteme')
        plot(haxM,x0M,y0M,'b.','tag','deleteme')
        if length(pts) >= 2
            plot(haxM,[xM+xval(pts(1))*cos(angle)/Mpsize xM+xval(pts(2))*cos(angle)/Mpsize],...
                [yM-xval(pts(1))*sin(angle)/Mpsize yM-xval(pts(2))*sin(angle)/Mpsize],...
                'r','linewidth',2,'tag','deleteme')
        end
        pause(0.5)
        if strcmp(get(hfig,'tag'),'closeme')
            show = false;
            delete(hfig)
        end
    end
        
    % Finally, define all entries in data(idx).
    data(idx).array = array;
    data(idx).xvalarray = linspace(0,L,size(array,3));
    data(idx).thickness = thickness; % mm
    data(idx).spacelat = spacelat;
    data(idx).spaceslice = spaceslice;
    data(idx).slicealignmenterror =  err;
    data(idx).Cslice = i;
    data(idx).Mslice = j;
    data(idx).angle = angle;
    data(idx).Ccentroid = centroid;
    data(idx).Cpoint = [x0,y0];
    data(idx).Mcentroid = centroidM;
    data(idx).Mpoint = [x0M,y0M];
    data(idx).wall = wall;
    data(idx).xvalwall = xval;
    
end

if show && ishandle(hfig)
    set(hfig,'CloseRequestFcn','delete(gcbo)')
end