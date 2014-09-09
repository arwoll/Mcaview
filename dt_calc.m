function [dtcorr, dtdel] = dt_calc(scandata)
% function [dtcorr, dtdel] = dt_calc(scandata)
%
% Calculates the dead_time correction for spectra in scandata, a structure
% generates by openmca.  Note that because matlab only pases values and
% because scandata holds all the data from a scan, this can be costly. But
% it does allow maximum flexibility.
% 
% saturated captures instances where the dead time is 100%...
errors = [];
saturated = [];
if strcmp(scandata.dead.key, 'vortex')
    switch scandata.dead.chan
        case 1
            % Dead time*1000 is stored in 1st channel of spectrum
            dead = scandata.mcadata(1,:,:)/1e5;
            saturated = find(dead == 1);
            dead(saturated) = -Inf;
            dtcorr = 1./(1-dead);
        case 2
            % Look for 'dead' ctr in spec file...
            dead_col = find(strcmpi('dead', scandata.spec.headers), 1);
            if ~isempty(dead_col)
                dead = scandata.spec.data(dead_col, :,:)/100.00;
                saturated = find(dead == 1);
                dead(saturated) = -Inf;
                dtcorr = 1./(1-dead);
            end
        case 3
            icr_col = find(strcmpi('ICR', scandata.spec.headers), 1);
            ocr_col = find(strcmpi('OCR', scandata.spec.headers), 1);
            real_col = find(strcmpi('seconds', scandata.spec.headers), 1);
            if isempty(real_col)
                real_col = find(strcmpi('sec', scandata.spec.headers), 1);
            end
            live_col = find(strcmpi('live', scandata.spec.headers), 1);
            if any(isempty([icr_col ocr_col real_col live_col]))
                dtcorr = 'Cannot perform dead-time calc, one or more spec data headers not found';
                return
            end
            if length([icr_col ocr_col real_col live_col]) == 4
                icr = scandata.spec.data(icr_col, :,:);
                ocr = scandata.spec.data(ocr_col, :,:);
                real = scandata.spec.data(real_col, :,:);
                live = scandata.spec.data(live_col, :,:);
                den = ocr.*live; 
                saturated = find(den == 0);
                den(saturated) = Inf;
                dtcorr = (icr.*real)./(den);
            else
                dtcorr = ones(size(scandata.spec.cttime));
            end
    end
    if ~isempty(saturated)
        warndlg(['dt_calc: At least one point, ' num2str(saturated(1)) ...
            ', had 100% dead time']);
    end
    dtcorr = squeeze(dtcorr);
    if size(dtcorr, 1) == 1
        dtcorr = dtcorr';
    end
    dtdel = ones(size(dtcorr))/1000;
elseif any(strcmp(scandata.dead.key, {'xflash', 'generic'}))
%     zero_dt_cts = Dead_time_base*scandata.spec.cttime(:);
%     dtcorr = 1.0+(zero_dt_cts-sum(scandata.mcadata(Dead_time_channels,:)))./zero_dt_cts;
    zero_dt_cts = scandata.dead.pulse_freq*scandata.spec.cttime;
    dead_cts = sum(scandata.mcadata(scandata.dead.chan,:,:));
    if any (dead_cts(:) > 2*zero_dt_cts)
        % This is a kludge for fixing points associated with a fill...
        badpts = find(dead_cts(:)>2*zero_dt_cts)';
        errors=add_error(errors, 2, ...
            [sprintf('Warning: Found %g bad dead-time correction pts.\n' , length(badpts)) ...
            'Some profiles may have bad points']);
    end
    if any(dead_cts(:) == 0)
        dtcorr = ones(size(scandata.spec.cttime));
        dtdel = dtcorr;
        errors=add_error(errors, 2, ...
            ['Warning: Dead Time Channels set, but at least\n' ...
            'one scan point has zero dead time counts']);
    end
    dtcorr = squeeze(zero_dt_cts./dead_cts);
    if size(dtcorr, 1) == 1
        dtcorr = dtcorr';
    end

    dtdel = (1.0+2./zero_dt_cts).*dtcorr;
else
    dtcorr = ones(size(scandata.spec.cttime));
    dtdel = dtcorr;
end

if ~isempty(errors)
    warndlg(strvcat({errors(:).msg}));
end
