function [specscan, errors] = openspec(specfilename, scan_number)
% function [specscan, error] = openspec(specfilename, scan_number)
%
% April 29 05 -- Now extracts scanx and scanz values from the scan 
% header and adds these to the specscan structure.  Values of
% SCANX_LOCATION and SCANZ_LOCATION refer to the row/column location of
% these motor values in the scan header, and also relate directly to
% the config file position.  These may change from run to run...
%
% specfilename  = Name of a spec file.
% 
% scan_number   = Desired scan number. 
%
% specscan      = structure containing info about the spec scan
%
% error.code = numerical indication of type
%              of error: 
%              0 = none
%              1 = spec file or scan not found
%              2 = spec scan is incomplete or other non-fatal error.
%               
% error.msg  = Error string
%
% Requires: tokenize.m (~woll/Matlab/woll_xrf), add_error,
% find_line, msgbox_nobutton
 
errors.code=0;
specscan = [];

%specscan = getscan(specfilename, scan_number); % specscan = -1 of file or scan not found

specfile = fopen(specfilename, 'r');
if specfile == -1
    errors = add_error(errors, 1, sprintf('Error: spec file %s not found',...
        specfilename));
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read in motor names from lines starting #O in spec file header.
% The regexp '\w+\s{1,1}\w+|\w+' works as long as motor names have no 
% more than one space in them (\w matches non-white space, \s matches white 
% space.  The alternate operator '|' is sequential, 
% so that it only attempts to match the right-hand regexp if the first one
% fails to match.  The leading #O[0-9] must be stripped first
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find the correct scan and abort if not found
[scanline, scan_mark, motor_mark] = find_scan(specfile, scan_number);

if ~ischar(scanline)
    errors = add_error(errors, 1, sprintf('Error: scan %d not found in %s\n', ...
        scan_number, specfilename));
    return
end

if motor_mark > -1
    fseek(specfile, motor_mark, -1);
    [tok, nextline] = strtok(fgetl(specfile));
    motor_names = [];
    if ischar(nextline)
        while length(tok)>1 && strcmp(tok(1:2),'#O')
            motor_names = [motor_names regexp(nextline, '[\w-]+\s{1,1}[\w-]+|[\w-]+', 'match')];
            nextline = fgetl(specfile);
            [tok, nextline] = strtok(nextline);
        end
    end
%    motor_names = reshape(motor_names(1:10), 5,2);
end
    
fseek(specfile, scan_mark,-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read in motor positions in the same fashion as the motor names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tok = '#P0';
nextline = find_line(specfile, tok);

motor_positions = [];
if ischar(nextline)
    while length(tok)>1 && strcmp(tok(1:2),'#P')
        motor_positions = [motor_positions sscanf(nextline,'%g')'];
        %mark = ftell(specfile);
        nextline = fgetl(specfile);
        [tok, nextline] = strtok(nextline);
    end
% The following seems obsolete, since I can test tok & nextline if
% seeking another header
%    fseek(specfile, mark,-1);
end

if length(motor_names) ~= length(motor_positions)
        errors = add_error(errors,2, sprintf('Warning: Found %d motor names, but %d motor positions.\n', ...
        length(motor_names), length(motor_positions)));
end

MCA_channels = 0;
ecal = [];
while ~strcmp(tok, '#L')
    if strcmp(tok, '#@CHANN')
        mcachan = tokenize(nextline);
        MCA_channels = str2double(mcachan{1});
        channels = (str2double(mcachan{2}):str2double(mcachan{3}))';
    elseif strcmp(tok, '#@CALIB')
        ecalcell = tokenize(nextline);
        for k = 1:length(ecalcell) 
            ecal(k) = str2double(ecalcell{k}); 
        end
    end
    nextline = fgetl(specfile);
    [tok, nextline] = strtok(nextline);
end

%headers = tokenize(find_line(specfile, '#L'));

headers = regexp(nextline, '[\w-]+\s{1,1}[\w-]+|[\w-]+', 'match');

columns = length(headers);

%datastr = '';
%lines = 0;

h = msgbox_nobutton('Loading Spec data, please wait...(patiently)', 'Open', 'warn');
[data_cell, stop_position] = textscan(specfile, '%f');
data=data_cell{1};

aborts = 0;
nextline = fgetl(specfile);
if nextline == -1
    tok = '';
else
    [tok, nextline] = strtok(nextline);
%    msgs=textscan(nextline, '%s');
%    msgs=msgs{1};
end

% while length(msgs) >= 8 && strcmp(msgs{1}, '#C')
% Note %f32 converts a float to a single-format floating-point
% 
% To accomodate multiple mca-type data, we need to have an extra field,
% mca_fields, e.g. {'AMCA', 'MCS1', 'MCS2'}. These fields should all be
% reshaped according to the scan dims. openmca that calls spec should call
% a dialog box to ask the user which mcadata to use if there is more than
% one.
mcadata = single([]);
while any(strcmp(tok, {'#C', '@A', '@AMCA', '@B'}))
    if strcmp(tok, '#C')
        aborts = aborts + 1;
        errors = add_error(errors, 2, nextline);
    else
        if ~MCA_channels
%           MCA data found but NO channel info.  Assume that the data is
%           on a single line.
            [mcadata, MCA_channels] = sscanf(nextline, '%f');
            mcadata = single(mcadata);
            channels = 1:MCA_channels;
        else
            fseek(specfile, stop_position+length(tok), -1);
            spectrum = textscan(specfile, '%f32', MCA_channels, 'whitespace', ' \b\t\\');
            mcadata(:,end+1) = spectrum{1};
        end
    end    
    [data_cell, stop_position] = textscan(specfile, '%f32');
    data = [data' data_cell{1}']';
    nextline = fgetl(specfile);
    if nextline == -1
        tok = '';
    else
        [tok, nextline] = strtok(nextline);
    end
end
 
close(h);   % Close spec file load box

fclose(specfile);

lines = length(data)/columns;

if ~lines
    errors = add_error(errors, 1, sprintf('No data found in scan %d of file %s\n',...
        scan_number,specfilename));
    return
end

specscan.data = reshape(data, columns, lines);

if ~isempty(mcadata)
    specscan.mcadata = mcadata;
    specscan.channels = channels;
end
if ~isempty(ecal)
    specscan.ecal = ecal;
end

specscan.scann = scan_number;
specscan.scanline = scanline;
specscan.npts = lines;
specscan.columns = columns;
specscan.headers = headers;
specscan.motor_names = motor_names;
specscan.motor_positions = motor_positions;

scan_pars = tokenize(specscan.scanline);
scan_type = char(scan_pars{1});

specscan.cttime = str2double(scan_pars{end});
if specscan.cttime <= 0
    cttime_col = find(strcmp(specscan.headers, 'Seconds'),1);
    specscan.cttime = specscan.data(cttime_col,:);
end

% specscan.complete = 1: scan is complete
%                     0: scan is incomplete, but no subsequent scan is
%                       present in file
%                     -1: scan is incomplete and the file has a subsequent
%                       scan, so the scan will never complete
specscan.complete = 1;
switch scan_type
    case 'tseries'
        specscan.ctrs = headers(3:end);
        specscan.var1 = specscan.data(1,:)';
        specscan.mot1 = 'time';

        planned_pts = str2double(scan_pars{2});
        if planned_pts > 0 && planned_pts ~= specscan.npts
            specscan.complete = 0;
        end
        specscan.dims = 1;
        specscan.size = specscan.npts;
    case 'ascan'        
        specscan.ctrs = headers(3:end);
        specscan.var1 = specscan.data(1,:)';
        specscan.mot1 = scan_pars{2};
        
        planned_npts = str2double(scan_pars{5})+1;
        if planned_npts ~= specscan.npts
            specscan.complete = -1*strcmp(tok, '#S');
        end
        specscan.dims = 1;
        specscan.size = specscan.npts;
    case 'a2scan'
        specscan.ctrs = headers(4:end);
        specscan.var1 = specscan.data(1,:)';
        specscan.mot1 = scan_pars{2};
        
        planned_npts = str2double(scan_pars{8})+1;
        if planned_npts ~= specscan.npts
            specscan.complete = -1*strcmp(tok, '#S');
        end
        specscan.dims = 1;
        specscan.size = specscan.npts;
    case {'smesh', 'mesh'}
        specscan.ctrs = headers(4:end);
        if strcmp(scan_type, 'smesh')
            var1_n = str2double(scan_pars{7})+1;
            var2_n = str2double(scan_pars{11})+1;
            specscan.mot2 = scan_pars{8};
        else % scan type is mesh
            var1_n = str2double(scan_pars{5})+1;
            var2_n = str2double(scan_pars{9})+1;
            specscan.mot2 = scan_pars{6};
        end
        specscan.mot1 = scan_pars{2};
        planned_npts = var1_n*var2_n;

        if planned_npts ~= specscan.npts
            specscan.complete = -1*strcmp(tok, '#S');
            specscan.extra = mod(specscan.npts, var1_n);
            if specscan.extra ~= 0
                specscan.npts = specscan.npts - specscan.extra;
                %specscan.var2 = specscan.var2(1:specscan.npts);
            end 
            var2_n = specscan.npts/var1_n;
            specscan.data=reshape(specscan.data(:,1:specscan.npts), ...
                columns, var1_n, var2_n);
            if ~isempty(mcadata)
                specscan.mcadata = reshape(specscan.mcadata(:,1:specscan.npts), ...
                MCA_channels, var1_n, var2_n);
            end

            if length(specscan.cttime)>1
                specscan.cttime = specscan.data(cttime_col, :, :);
            end
        else
            specscan.data=reshape(specscan.data,columns, var1_n, var2_n);
            if length(specscan.cttime)>1
                specscan.cttime = reshape(specscan.cttime, var1_n, var2_n);
            end
            if ~isempty(mcadata)
                specscan.mcadata = reshape(specscan.mcadata,MCA_channels, var1_n, var2_n);
            end
        end
        specscan.var1 = squeeze(specscan.data(1,:,:)); 
        specscan.var2 = squeeze(specscan.data(2,:,:));
        specscan.dims = 2;
        specscan.size = [var1_n var2_n];
    case 's2mesh'
        specscan.ctrs = headers(5:end);
        var1_n = str2double(scan_pars{7})+1;
        var2_n = str2double(scan_pars{11})+1;
        var3_n = str2double(scan_pars{15})+1;
        
        n_fast = var2_n * var3_n; % number of fast-scan loops
        
        planned_npts = var1_n*var2_n*var3_n;
        
        specscan.mot1 = scan_pars{2};
        specscan.mot2 = scan_pars{8};
        specscan.mot3 = scan_pars{12};
        
        if planned_npts ~= specscan.npts
            % Keep only the last complete var1 (fast) loop
            specscan.complete = -1*strcmp(tok, '#S');
            specscan.extra = mod(specscan.npts, var1_n);
            if specscan.extra ~= 0
                specscan.npts = specscan.npts - specscan.extra;

            end
            n_fast = specscan.npts/var1_n;
            var3_n = ceil(n_fast/var2_n);
            if n_fast < var2_n
                var2_n = n_fast;
            end
            specscan.data=reshape(specscan.data(:,1:specscan.npts), ...
                columns, var1_n, n_fast);  
            if ~isempty(mcadata)
                specscan.mcadata = reshape(specscan.mcadata(:,1:specscan.npts), ...
                    MCA_channels, var1_n, n_fast);
            end
            if length(specscan.cttime)>1
                specscan.cttime = specscan.data(cttime_col, :, :);
            end
        else
            specscan.data=reshape(specscan.data,columns, var1_n, n_fast);
            if ~isempty(mcadata)
                specscan.mcadata = reshape(specscan.mcadata, MCA_channels, var1_n, n_fast);
            end
            if length(specscan.cttime)>1
                specscan.cttime = reshape(specscan.cttime, var1_n, n_fast);
            end
        end
        specscan.var1 = squeeze(specscan.data(1,:,:));
        specscan.var2 = squeeze(specscan.data(2,:,:));
        specscan.var3 = squeeze(specscan.data(3,:,:));
        % Note that specscan.npts can be less than var1_n * var2_n *
        % var3_n, since the data are truncated to the last complete fast
        % scan.  Hence specscan.npts = n_fast * var1_n = (var3_n - 1) *...
        % (var2_n*var1_n) + (n_fast- (var3_n-1)*var2_n) * var1_n
        specscan.dims = 3;
        specscan.size = [var1_n var2_n var3_n];
    case 's2zoom'
        specscan.ctrs = headers(5:end);
        var1_inc = str2double(scan_pars{5});
        var2_n = str2double(scan_pars{9})+1;
        var3_n = str2double(scan_pars{13})+1;
        
        % The order vars are +1 for ascending, -1 for descending
        var3_order = 2 * (str2double(scan_pars{12}) > str2double(scan_pars{11})) - 1;
        var2_order = 2 * (str2double(scan_pars{8}) > str2double(scan_pars{7})) - 1;
        n_fast = var2_n * var3_n; % number of fast-scan loops
               
        specscan.mot1 = scan_pars{2};
        specscan.mot2 = scan_pars{6};
        specscan.mot3 = scan_pars{10};
        
        % First, sort the data so that it makes a nice array, and save the
        % order to apply to the mcadata.  This could be time consuming...
        [sorted_data, specscan.order] = sortrows(specscan.data', ...
            [var3_order*3 var2_order*2 1]);
        sorted_data = sorted_data';
        
        n_fast_actual = 1;
        var1_n(1) = 1;
        lat_posn = sorted_data(2:3, 1);
        for k = 2:specscan.npts
            if all(lat_posn == sorted_data(2:3,k))
                var1_n(n_fast_actual) = var1_n(n_fast_actual)+1;
            else
                n_fast_actual = n_fast_actual+1;
                var1_n(n_fast_actual) = 1;
                lat_posn = sorted_data(2:3, k);
            end
        end
        max_var1 = max(var1_n);
        
        % Here, we need to fill out the matrix, or at least figure out how
        % to do so for the sake of the mcadata, or do we? We need to be
        % able pass info about how to properly reshape mcadata...
        specscan.data = zeros(columns,max_var1, n_fast_actual);
        start = 1;
        for k = 1:n_fast_actual
            specscan.data(:,1:var1_n(k),k) = ...
                sorted_data(:,start:start+var1_n(k)-1);
            specscan.data(1, var1_n(k)+1:max_var1, k) = ...
                specscan.data(1,var1_n(k),k)+var1_inc*[1:max_var1-var1_n(k)];
            specscan.data(2:3, var1_n(k)+1:max_var1, k) = ...
                repmat(specscan.data(2:3, 1, k), 1,max_var1-var1_n(k));
            start = start+var1_n(k);
        end
        
        if n_fast_actual ~= n_fast
            specscan.complete = -1*strcmp(tok, '#S');
        end
        n_fast = n_fast_actual;
        var3_n = ceil(n_fast/var2_n);
        if n_fast < var2_n
            var2_n = n_fast;
        end
        if ~isempty(mcadata)
            sorted_mcadata = specscan.mcadata(:,specscan.order);
            specscan.mcadata = zeros([MCA_channels, max_var1, n_fast]);
            start = 1;
            for k = 1:n_fast
                specscan.mcadata(:,1:var1_n(k), k) = ...
                    sorted_mcadata(:, start:start+var1_n(k)-1);
                start = start+var1_n(k);
            end
        end
        if length(specscan.cttime)>1
            specscan.cttime = specscan.data(cttime_col, :, :);
        end

        specscan.var1_n = var1_n;  % An array, necessary to re-order mcadata later...
        specscan.var1 = squeeze(specscan.data(1,:,:));
        specscan.var2 = squeeze(specscan.data(2,:,:));
        specscan.var3 = squeeze(specscan.data(3,:,:));

        specscan.dims = 3;
        specscan.size = [max_var1 var2_n var3_n];
    otherwise
        errors=add_error(errors,1,sprintf('Error: Unrecognized scan type, scan %g in %s',...
            scan_number, specfilename));
        return
end % -------- switch -------------


function [scanline, varargout] = find_scan(specfile, scan)
% [scanline, varargout] = find_scan(specfile, scan)
% Assumes specfile is alredy open. Makes no noise if the scan is not found.
%
% if present, varargout should have two elements. They are the file
% position of the scan and motor position lines, respectively.
if nargout > 1
    varargout = {-1, -1};
end
while 1
    [scanline, index, mark] = find_line(specfile, {'#S', '#O0'});
    if ~ischar(scanline)
        break
    end
    if nargout > 1 
        varargout{index} = mark;
        if index == 2
            continue
        end
    end

    [S, scanline] = strtok(scanline);
    if strcmp(S, sprintf('%d', scan))
        %scan_found = 1;
        scanline = scanline(find(scanline~=' ',1):end);
        break
    end
end
%scanline = textline;

