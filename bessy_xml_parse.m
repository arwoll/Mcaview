function [scandata, errors] = bessy_xml_parse(mcafile)
% function [scandata, errors] = bessy_xml_parse(mcafile)
% Very simple-minded parser for Wolfgang Malzer's xml data file format.
% Makes use of xmlread and java based xml methods -- see 'doc xmlread' in Matlab Help

tic
h = msgbox('Loading MCA data, please wait...(patiently)', 'Open', 'warn');

xdoc = xmlread(mcafile);
% Probably should grab some of the header info here...

[mcapath, mcaname, extn] = fileparts(mcafile);

%% Initialization
errors.code = 0;
% Initialize scandata structure and spec substructures:
spec = struct('data', [],'scann',1,'scanline', '', 'npts', [],...
    'columns', 0,'headers',{{}},'motor_names',{{}},'motor_positions', [],...
    'cttime', [],'complete',1,'ctrs',{{}},'mot1','', 'var1',[],...
    'dims', 1,'size', []);

scandata = struct('spec', spec, 'mcadata',[], 'mcaformat', 'bessy_xml', 'dead', struct('key',''), ...
    'depth', [], 'channels', [], 'mcafile', [mcaname extn], 'ecal', [], 'energy', [], ...
    'specfile',[mcaname extn], 'dtcorr', [], 'dtdel', [], 'image', {{}});

%%
rawdata = xdoc.getElementsByTagName('result.Gresham1');
ecal_element = rawdata.item(0).getElementsByTagName('SpectraCalibration');
scandata.ecal = sscanf(char(ecal_element.item(0).getFirstChild.getNextSibling.getFirstChild.getData), '%f')';
preset = rawdata.item(0).getElementsByTagName('Preset');
scandata.spec.cttime = sscanf(char(preset.item(0).getFirstChild.getData), '%f');
position = [0 0 0];
for k = 0:rawdata.getLength-1
    list = rawdata.item(k).getElementsByTagName('LIST');
    mcadata(:,k+1) = sscanf(char(list.item(1).getFirstChild.getData), '%d');
    real = rawdata.item(k).getElementsByTagName('Realtime');
    realtime(k+1) = sscanf(char(real.item(0).getFirstChild.getData), '%f');
    dead = rawdata.item(k).getElementsByTagName('Deadtime');
    dt(k+1) = sscanf(char(dead.item(0).getFirstChild.getData), '%f');
    target_info = rawdata.item(k).getNextSibling;
    while (target_info.getNodeType ~= target_info.ELEMENT_NODE) || ...
            (~isempty(target_info) && ~strcmp('result.TargetStage', char(target_info.getTagName)))
        target_info = target_info.getNextSibling;
    end
    if isempty(target_info)
        errors = add_error(errors, 1, 'could not find target stage node in in bessy_xml_parse');
        return
    end
    position_field = target_info.getElementsByTagName('Position');
    position(k+1,:) = sscanf(char(position_field.item(0).getFirstChild.getData), '%f');
end
scandata.dtcorr = 1./(1-dt');
scandata.dtdel = ones(size(scandata.dtcorr));
close(h);

fprintf('xml import elapsed time:\n');
toc

MCA_channels = size(mcadata, 1);
spectra = size(mcadata, 2);
channels = [0:(MCA_channels-1)]';

scandata.spec.npts = spectra;
scandata.spec.size = spectra;
scandata.spec.data = position';
scandata.spec.data(4:5, :) = [dt ; realtime];
scandata.spec.columns = 3;
scandata.spec.headers={'scanx', 'scany', 'scanz', 'dead','sec'};
scandata.spec.ctrs = {'dead','sec'};
scandata.spec.motor_names = {'scanx', 'scany', 'scanz'};
scandata.spec.motor_positions = position(1,:);
scandata.spec.mot1 = 'scany';
scandata.spec.var1 = position(:,2);

scandata.mcadata = single(mcadata);
scandata.depth = 1:size(mcadata, 2);
scandata.channels = channels; 
scandata.energy = channel2energy(scandata.channels, scandata.ecal);


% matfile format is now determined farther up...
% matfile = strrep(mcafile, '.mca', '.mat');
fullmatfile = fullfile(mcapath, [mcaname '.mat']);
if exist(fullmatfile, 'file')
    overwrite = questdlg(sprintf('Overwrite existing file %s?', ...
        fullmatfile), 'Overwrite?', 'Yes', 'No', 'Yes');
    if strcmp(overwrite, 'Yes')
        save(fullmatfile,'scandata');
    end
else
    save(fullmatfile,'scandata');
end

% full scandata:
%          spec: [1x1 struct]
%       mcadata: [1024x51x21 single]
%     mcaformat: 'chess1'
%          dead: [1x1 struct]
%         depth: [1x1071 double]
%      channels: [1024x1 double]
%       mcafile: 'teniers5_34.mca'
%          ecal: [-0.4681 0.0199 8.8771e-08]
%        energy: [1024x1 double]
%      specfile: 'teniers5'
%        dtcorr: [51x21 single]
%         dtdel: [51x21 single]
%         image: {1x21 cell}


% scandata.spec
% ans = 
%                data: [10x51x21 double]
%               scann: 34
%            scanline: 'smesh  scany 33.2 33.6 -0.05 0.25 50  scanz 294.3 274.3 20  2'
%                npts: 1071
%             columns: 10
%             headers: {1x10 cell}
%         motor_names: {1x58 cell}
%     motor_positions: [1x58 double]
%              cttime: 2
%            complete: 1
%                ctrs: {'sec'  'Itot'  'Iprot'  'mca'  'CESR'  'Imon'  'Idet'}
%                mot2: 'scanz'
%                mot1: 'scany'
%                var1: [51x21 double]
%                var2: [51x21 double]
%                dims: 2
%                size: [51 21]