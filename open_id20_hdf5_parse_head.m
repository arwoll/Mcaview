function out_struct = open_id20_hdf5_parse_head(header_str)
% function out_struct = open_id20_hdf5_parse_head(header_str)
%
% Parses the more or less standard Labview-type header from ID20 (found
%        in the hdf5 file in this particular case to extract various
%        information, especially about the ion chamber voltages and
%        sensitivities. 
% 
% Note that this technique (reading the whole string at once, then using
% strfind to isolate and parse substrings) is probably much faster than the
% original method used for ID20 text output.
% 
%
% Note too: 2D scans, for some reason, do not include cttime...
%
% TODO:
%      1. Testing -- Done
%      2. Add Error Checks.
%      3. Documentation

out_struct = [];

ion_chambers = struct('name', {}, 'sensitivity', {}, ...
    'V0', {}', 'V1', {}); % Sensitivity in A/V

line_starts = strfind(header_str, '#');
line_feeds = strfind(header_str, char(10));

%---------------------------------------------%
%--------------- Get Count time --------------%
%---------------------------------------------%
search_str = 'Integration time';
location = strfind(header_str, search_str);
if isempty(location)
    fprintf('Warning: While parting header -- no Integration time line found\n');
else
    field_start = location + length(search_str);
    field_end = line_feeds(find(line_feeds > location,1));
    if ~isempty(location)
        cttime = sscanf(header_str(field_start : field_end), '%f', 1);
    end
end

%---------------------------------------------%
%-------------- Get Sensitivities ------------%
%---------------------------------------------%
search_str = 'Sensitivities';
location = strfind(header_str, search_str);
if isempty(location)
    fprintf('Warning: While parting header -- no Integration time line found\n');
    ics_found = 0;
else
    field_start = line_starts(find(line_starts > location, 1)) + 1; % start of next line, omitting leading '#'
    field_end = line_feeds(find(line_feeds > field_start,1));
    foo = textscan(header_str(field_start : field_end), ...
        '%s %f %s', 'Delimiter', {' ','\t','\b', ':'}, 'MultipleDelimsAsOne', 1);
    for k = 1:length(foo{1})
        ion_chambers(k).name = foo{1}{k};
        ion_chambers(k).sensitivity = foo{2}(k);
        switch foo{3}{k}
            case 'nA/V'
                ion_chambers(k).sensitivity = ion_chambers(k).sensitivity * 1e-9;
            case 'pA/V'
                ion_chambers(k).sensitivity = ion_chambers(k).sensitivity * 1e-12;
        end
    end
    ics_found = 1;
end

%---------------------------------------------%
%--------- Get Start/End IC Voltages ---------%
%---------------------------------------------%
search_str = 'Analog Input Voltages';
location = strfind(header_str, search_str);
if isempty(location) || ~ics_found
    fprintf('Warnign : While parting header -- Analog Input Voltages not found\n');
else
    field_start = line_starts(find(line_starts > location, 1)) + 1; % start of next line, omitting leading '#'
    field_end = line_feeds(find(line_feeds > field_start,1));
    ic_names = {ion_chambers.name};
    foo = textscan(header_str(field_start : field_end), ...
        '%s %f %f','Delimiter', {' ','\t','\b', ':', '/'}, 'MultipleDelimsAsOne', 1);
    for k = 1:length(foo{1})
        this_ic = strcmp(foo{1}{k}, ic_names);
        if any(this_ic)
            ion_chambers(this_ic).V0 = foo{2}(k);
            ion_chambers(this_ic).V1 = foo{3}(k);
        end
    end
end

%---------------------------------------------%
%--------------- Get XIA Filters -------------%
%---------------------------------------------%
search_str = 'XIA Filters';
location = strfind(header_str, search_str);
if isempty(location)
    fprintf('While parting header -- XIA Filters not found\n');
    return
else
    field_start = line_starts(find(line_starts > location, 1)) + 1; % start of next line, omitting leading '#'
    field_end = line_feeds(find(line_feeds > field_start,1));
    foo = textscan(header_str(field_start : field_end),  '%s %s', ...
        'Delimiter', {' ','\t','\b', ':'}, 'MultipleDelimsAsOne', 1);
    inouts = strcmp(foo{2},'IN');
    vals = [1 2 4 8];
    filters = vals * inouts;
end

%---------------------------------------------%
%--------------- XIA Shutter Unit ------------%
%---------------------------------------------%
search_str = 'XIA Shutter Unit';
location = strfind(header_str, search_str);
if isempty(location)
    fprintf('While parting header -- XIA Shutter Unit not found\n');
    return
else
    field_start = line_starts(find(line_starts > location, 1)) + 1; % start of next line, omitting leading '#'
    field_end = line_feeds(find(line_feeds > field_start,1));
    foo = textscan(header_str(field_start : field_end),  '%s %s', ...
        'Delimiter', {' ','\t','\b', ':'}, 'MultipleDelimsAsOne', 1);
    inouts = strcmp(foo{2},'IN');
    vals = [1 2];
    shutters = vals * inouts;
end

out_struct.ion_chambers = ion_chambers;
out_struct.xia_filters = filters;
out_struct.xia_shut = shutters;


