function [scandata, errors] = openmca(mcafile, varargin)
%  function scandata = openmca(mcaname [,varargin])
%
%  for mcaview-0.99: For efficiency, change mcadata to uint16s, convert to sparce matrices?
%
%  Based on mcagui-0.6/openmca, mcagui-0.6/openmca_esrf.  Can accept an
%  'mcaformat' parameter (currently 'xflash' and 'esrf' types are allowed).
%  If no format it specified it tries to autodetect and proceed. This
%  will make it far easier to add different formats or different
%  mcafile/specfile relationships.
%
%  mcafile    = Name of mca file.  Should be of the form <specfile>_#.mca,
%               Optionally it can be a matlab file containing a variable called
%               'scandata' with the structure defined below
%
%  varargin   = property/value pairs to specify non-default values for mca
%               data.  Allowed properties are:
%               'ecal'          : 1x2 array for channel # to energy conversion
%               'MCA_channels'  :
%               'dead'          : dead.base, dead.channels specify how to get dead
%                                 time info
%               'mcaformat'     : to expand allowed formats. Currently only two
%                                 are allowed, 'esrf' and 'xflash', and these can be
%                                 auto-detected.
%
%  scandata   = mca data structure combining mca, spec, and fitting data.
%
%  errors.code = numerical indication of type
%               of error: 
%               0 = none
%               1 = scandata is empty (file not found or other fatal error)
%               2 = scandata is present but may be incomplete, or some other non-fatal 
%                   error condition, e.g. no spec data, mcafile was incomplete)
%
%
%
%  errors.msg  = Error string
%
%  Opens and loads data from an mca file ('*.mca')
%
%  If it is a .mca file, looks for corresponding spec file to load scan
%  parameters (e.g. scan range and the integration time).  If no spec file
%  is found, the file is interpreted as a single mca spectrum and errors.string 
%  will be non-empty
%
%  Dependencies: add_error, openspec, channel2energy, find_line, mca_strip_pt
%
% -------------------------------------------------------------------------
% -----------------         Initialization         ------------------------
% -------------------------------------------------------------------------

errors.code = 0;
scandata = [];
specscan = [];
mcadata = uint16([]);

if nargin < 1 
    errors=add_error(errors,1,...
        'openmca takes at least one input -- the filename');
    return
elseif ~exist(mcafile)
    errors=add_error(errors,1, ...
        sprintf('File %s not found', mcafile));
    return
end

nvarargin = nargin -1;
if mod(nvarargin, 2) ~= 0
    errordlg('Additional args to openmca_esrf must come in variable/value pairs');
    return
end

MCA_channels = 1024;
ecal = [0 1];

%xflash_pulse_freq = 1048;  % counts in first 40 channels per second when there is no dead time.
%xflash_dead_channels = 1:40;

mcaformat = ''; % If this remains empty after processing args, code will try to autodetect
dead = struct('key','');

for k = 1:2:nvarargin
    switch varargin{k}
        case 'MCA_channels'
            if isnumeric(varargin{k+1}) || length(varargin{k+1}) == 1
                MCA_channels = varargin{k+1};
            end
        case 'ecal'
            if isnumeric(varargin{k+1})
                ecal = varargin{k+1};
            end
        case 'dead'
            % fields key (none, vortex, xflash, generic)
            %        channels (1:40 for xflash, 1, 2, or 3 for vortex,
            %            other for generic, empty for none
            %        pulse_freq: non-empty for xflash, generic
            %        tau: non-empty for vortex
            fields = fieldnames(varargin{k+1});
            for m = 1:length(fields)
                dead.(fields{m}) = varargin{k+1}.(fields{m});
            end
        case 'mcaformat'
            % formats: spec (all data in the spec file)
            %          g2 (all spectra in their own spec files)
            %          chess1 (all scan spectra in file <specfile>_#.mca)
            %          chess3 (all scan spectra in file <specfile>_###.mca)
            %          chess1_sp (special format <specfile>_#.#.mca for
            %          multiple mcas)
            mcaformat = varargin{k+1};
        case 'scan'
            specscan = varargin{k+1};
        otherwise
            warndlg(sprintf('Unrecognized variable %s',varargin{k}));
    end
end       

% -------------------------------------------------------------------------
% -----------------   Autodetect mca format if needed     -----------------
% -------------------------------------------------------------------------

[mcapath, mcaname, extn] = fileparts(mcafile);

if any(strcmp(mcaformat, {'', 'chess1', 'chess3','chess_sp'}))
    mcafid = fopen(mcafile, 'rt');
    first = fgetl(mcafid);
    if strcmp(first(1:2), '#F')
        % This is an mca file with spec info.  Prompt for which type...
        mcaformat = {'spec', 'g2'};
    else
        if regexp(mcaname, '^[\w\.]+\.\d+')
            mcaformat = 'chess_sp';
        elseif regexp(mcaname, '^[\w\.]+_\d{3}')
            mcaformat = 'chess3';
        elseif regexp(mcaname, '^[\w\.]+_\d+')
            mcaformat = 'chess1';
        end
        if strcmp(first(1:2), '#M')
            [field, rem] = strtok(first(2:end));
            if any(strcmp(field, {'MCA_NAME', 'MCA_NAME:'}))
                dead.key = strtok(rem);
                first = fgetl(mcafid);
                [field, rem] = strtok(first(2:end));
            end
            if any(strcmp(field, {'MCA_CHAN','MCA_CHAN:','MCA:'}))
                MCA_channels = strread(rem, '%d');
                autodetect_channels = 0;
            else
                autodect_channels = 1;
            end
        else
            autodetect_channels = 1;
        end
    end
    fclose(mcafid);
end

if isempty(mcaformat)
    errordlg('Unrecognized mca file format...abort');
    return
elseif iscell(mcaformat) && length(mcaformat) == 1
    mcaformat = mcaformat{1};
end

if iscell(mcaformat) || isempty(dead.key) || ...
        (strcmp(dead.key,'xflash') && ~isfield(dead, 'pulse_freq')) || ...
        (strcmp(dead.key,'vortex') && ~isfield(dead, 'chan')) || ...
        (strcmp(dead.key, 'generic') && ...
            (~isfield(dead, 'chan') || ~isfield(dead, 'pulse_freq')))
        
        [mcaformat, dead] = openmca_settingsdlg(mcaformat, dead);
end


% -------------------------------------------------------------------------
% --------------------------     Load MCA data      -----------------------
% -------------------------------------------------------------------------

% The block below reads in mca data when it is contained in a file other
% than the spec data file.  In this case, unless error code has been set to
% 1, the following variables must be defined:
%   1. specfile
%   2. Dead_time_base, Dead_time_channels
%   3. matfile
%   4. mcadata
%   5. MCA_channels
%   6. spectra
%   7. channels (explict channel numbers for energy calibration)

switch mcaformat
    case 'spec'
        if isempty(specscan)
            specscan = inputdlg('Scan number?', 'Open',1,{'1'});
            specscan = sscanf(specscan{1}, '%d', 1);
        end
        specfile = [mcaname extn];
        matfile = sprintf('%s_%03d.mat',specfile,specscan);
    case 'g2'
        mcafid = fopen(mcafile, 'rt');
        mcachan = textscan(find_line(mcafid, '#@CHANN'), '%s'); mcachan = mcachan{1};
        fclose(mcafid);
        MCA_channels = str2double(mcachan{1});
        channels = [str2double(mcachan{2}):str2double(mcachan{3})]';
        mcabase = mca_strip_pt(mcaname);  % mcabase has format 'specfile_scann'
        [specfile, specscan] = mca_strip_pt(mcabase);

        % Both specfile and mcabase must be non-empty for us to assume that
        % the requested mca file is one of a set.
        if ~isempty(specfile)
            mcafiles = dir(fullfile(mcapath,[mcabase '_*' extn]));
            mcafiles = {mcafiles.name}';
        else
            mcafiles = {mcafile};
        end
        for spectra = 1:length(mcafiles)
            mcadata(:,spectra) = textread(fullfile(mcapath,mcafiles{spectra}), '%f', ...
                MCA_channels, 'commentstyle' ,'shell', 'whitespace', ' \b\t@A\\');
        end
        matfile = [mcabase '.mat'];
    case {'chess1', 'chess3', 'chess_sp'}
        [specfile, specscan] = mca_strip_pt(mcaname);
        
        if autodetect_channels
            % Looks for first empty line...
            MCA_channels = 0;
            mcafid=fopen(mcafile, 'rt');
            while ~feof(mcafid);
                foo = fgetl(mcafid);
                if length(foo)>0
                    if foo(1) ~= '#'
                        MCA_channels = MCA_channels+1;
                    end
                else
                    break
                end
            end
            fclose(mcafid);
        end
        
        tic;
        h = msgbox('Loading MCA data, please wait...(patiently)', 'Open', 'warn');
        
        
        % textread is as much as 50% faster than textscan, but does not provide an
        % unsigned 16-bit integer format. mcaview-0.99 switched from textread to textscan 
        % mcadata = textread(mcafile, '%*d%f', 'commentstyle', 'shell');
        mcafid = fopen(mcafile, 'rt');
        mcadata = textscan(mcafid, '%*d%u16' ,'commentStyle', '#');
        fclose(mcafid);
        mcadata = mcadata{1};
        close(h);
        fprintf('mca file read elapsed:\n');
        toc
        channels = [0:(MCA_channels-1)]';
        mcapts = length(mcadata);
        spectra = floor(mcapts/MCA_channels);
        if mod(mcapts,MCA_channels) ~= 0
            % MCA data doesn't have an even number of spectra.
            errors = add_error(errors, 2, ...
                sprintf('Warning: mca data file %s has %d lines, not a multiple %g channels', ...
                mcafile, mcapts, MCA_channels));
            spectra = spectra - 1;
            mcadata = mcadata(1:spectra*MCA_channels);
        end
        mcadata = reshape(mcadata, MCA_channels, spectra);
        matfile = [mcaname '.mat'];
    otherwise
        errors=add_error(errors,1,...
            sprintf('Uncrecognized mca file format %s', mcaformat));
        return
end

% -------------------------------------------------------------------------
% -----------------          Load spec data         -----------------------
% -------------------------------------------------------------------------
% At this point mcafile and mcadata are determined. However, mcadata may
% be reshaped if 1) a spec scan is located and has more than one point, or
% 2) no spec file is found but the length of mcadata is an integer
% multiple of MCA_channels.
% -------------------------------------------------------------------------
if strcmp(mcaformat, 'spec')
    h = msgbox('Loading MCA data, please wait...(patiently)', 'Open', 'warn');
    warnon = 1;
else
    warnon = 0;
end
%tic
[scandata.spec, spec_err] = openspec(fullfile(mcapath,specfile), specscan);
%fprintf('spec file read elapsed:\n');
%toc
if warnon
    close(h);
end

if spec_err(end).code > 0
    % Demote fatal error from openspec since at this point we have
    % successfully read in mcadata (we are just missing spec info)
    % Oops -- currently the following message is added twice...
    for k = 1:length(spec_err)
        errors = add_error(errors, spec_err(k).code, spec_err(k).msg);
    end
    if errors(end).code == 1
       % if errors(end).code == 1 && ~strcmp(mcaformat,'spec')
        % In this case, we have loaded mca data from a different file, so
        % we can demote the spec level 1 (critical) error
        %
        % Ack -- this is not currently supported -- I am currently relying on the spec file
        % being successfully loaded.  If I do want to support this mode,
        % the easiest way would probably to load scandata.spec with the
        % bare minimum pars -- e.g. dims, size, mot1 at least...
%        errors(end).code = 2;
        return
    end
end

if strcmp(mcaformat, 'spec')
    if isfield(scandata.spec, 'mcadata')
    mcadata = scandata.spec.mcadata;  
    channels = scandata.spec.channels;
    rmfield(scandata.spec,{'mcadata', 'channels'});
    if isfield(scandata.spec, 'ecal')
       ecal = scandata.spec.ecal; 
       rmfield(scandata.spec,'ecal');
    end
    mcasize = size(mcadata);
    MCA_channels = mcasize(1);
    spectra = prod(mcasize(2:end));
    else
        errors = add_error(errors, 1, 'MCA data was not found in spec file...');
        return
    end
end

scandata.mcadata = mcadata;
scandata.mcaformat = mcaformat;
scandata.dead = dead;
scandata.depth = 1:size(mcadata, 2);
scandata.channels = channels; 
scandata.mcafile = [mcaname extn];
scandata.ecal = ecal;
scandata.energy = channel2energy(scandata.channels, ecal);


scandims = size(scandata.spec.data);
if isfield(scandata.spec, 'order')
    % The order field in scandata.spec indicates that the data were not
    % originally ordered in a perfect grid -- e.g. the raster scan switched
    % directions to save time. This could be a 2D OR 3D scan.  A second
    % field, var1_n, takes care of the fact that the different directions
    % may not have different sizes.  
    sorted_mcadata = scandata.mcadata(:,scandata.spec.order);
    scandata.mcadata = zeros([MCA_channels, scandata.spec.size(1), ...
        length(scandata.spec.var1_n)]);
    start = 1;
    for k = 1:length(scandata.spec.var1_n)
        scandata.mcadata(:,1:scandata.spec.var1_n(k), k) = ...
            sorted_mcadata(:, start:start+scandata.spec.var1_n(k)-1);
        start = start+scandata.spec.var1_n(k);
    end
    spectra = scandata.spec.npts;
else
    if ~scandata.spec.complete
        % Truncate the mcadata to whole number of var2_n
        if spectra > scandata.spec.npts
            scandata.mcadata = scandata.mcadata(:, 1:scandata.spec.npts);
            scandata.depth = scandata.depth(1:scandata.spec.npts);
            spectra = scandata.spec.npts;
        elseif spectra < scandata.spec.npts
            fprintf('Fewer spectra than spec pts written -- sometimes happens when loading a current scan\n')
            scandata.spec.npts = specscan.spec.npts - 1;
        end
    end
    if length(scandims)>2
        scandata.mcadata=reshape(scandata.mcadata, MCA_channels, scandims(2), scandims(3));
    end
end
    
if spectra ~= scandata.spec.npts
    % scandata.spec.npts is supposed to be the number of spec data points
    % actually read, rather than the number of points expected.  Hence this
    % is a true error condition since the number of spec points written
    % does not match the number of mca spectra.  This is distinct from an
    % incomplete scan, in which case these values should match but
    % scandata.spec.complete == 0 so that the condition is caught above
    errors=add_error(errors, 1, ...
        sprintf('Error: mcafile / specfile mismatch. Check %s for duplicate scans',specfile));
    return
end

scandata.specfile = specfile;
%scandata.depth = scandata.spec.var1-scandata.spec.var1(1);

%Dead Time correction: MUST be caclulated after reshaping mcadata.
try
    [scandata.dtcorr,  scandata.dtdel] = dt_calc(scandata);
catch
    errors=add_error(errors,1,scandata.dtcorr);
    return;
end

% Look for & input names of image file(s). This was implemented in April 05
% to take advantage of a fram grabber running from spec.
imagefile = strrep(matfile, '.mat', '.jpg');
if exist(fullfile(mcapath,imagefile), 'file')
%    scandata.image = imagefile);
%    [path name extn] =fileparts(imagefile);
    scandata.image = {imagefile};
    if length(scandims)>2
        for k=1:scandims(3)
            nextimage = strrep(imagefile, '.jpg', sprintf('_%g.jpg',k));
            if exist(fullfile(mcapath, nextimage), 'file')
                scandata.image{k}=nextimage;
            end
        end
    end
end

fullmatfile = fullfile(mcapath, matfile);
if exist(fullmatfile, 'file')
    overwrite = questdlg(sprintf('Overwrite existing file %s?', ...
        fullmatfile), 'Overwrite?', 'Yes', 'No', 'Yes');
    if strcmp(overwrite, 'Yes')
        save(fullmatfile,'scandata');
    end
else
    save(fullmatfile,'scandata');
end
