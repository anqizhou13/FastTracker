function [RHJC, LHJC] = HJCprediction(LASIS, LPSIS, RASIS, RPSIS)
% Prediction of the hip joint center through the method of M.E. Harrington.
% Pelvis width (PW).
% Pelvis Depth (PD).
% measures in mm:
%           x = - 0.24 PD - 9.9
%           y = - 0.30 PW - 10.9
%           z = + 0.33 PW + 7.3
%
%   Syntax:
%           [RHJC, LHJC] = HJCprediction(filename)
%           [RHJC, LHJC] = HJCprediction(acquisition)
%
%   Parameters:
%           filename	Path of the file to load.
%           acquisition Structure with the biomechanical values.
%
%   Return values:
%           RHJC        Rigth hip joint centre.
%           LHJC        Left hip joint centre.

% Get HJC Markers: LASIS, LPSIS, RASIS, RPSIS

% Check for magnitude
mmcm=1;
if RASIS(1,2)<300
    mmcm=10;
end

nFrame = length(LASIS);

for iFrame = 1 : nFrame
    
    SACRUM(:, iFrame) = (RPSIS(:, iFrame) + LPSIS(:, iFrame))/2;
    OP(:, iFrame) = (LASIS(:, iFrame) + RASIS(:, iFrame))/2;
    
    PROVV(:, iFrame) = (RASIS(:, iFrame) - SACRUM(:, iFrame))/norm(RASIS(:, iFrame) - SACRUM(:, iFrame));
    IB(:, iFrame) = (RASIS(:, iFrame) - LASIS(:, iFrame))/norm(RASIS(:, iFrame) - LASIS(:, iFrame));
    
    KB(:, iFrame) = cross(IB(:, iFrame),PROVV(:, iFrame));
    KB(:, iFrame) = KB(:, iFrame)/norm(KB(:, iFrame));
    
    JB(:, iFrame) = cross(KB(:, iFrame),IB(:, iFrame));
    JB(:, iFrame) = JB(:, iFrame)/norm(JB(:, iFrame));
    
    OB(:, iFrame) = OP(:, iFrame);
    
    pelvis(:, :, iFrame) = [IB(:, iFrame) JB(:, iFrame) KB(:, iFrame)];

    PW(iFrame) = norm(RASIS(:, iFrame) - LASIS(:, iFrame));
    PD(iFrame) = norm(SACRUM(:, iFrame) - OP(:, iFrame));
    
    % Harrington formulas from pelvis center
    diff_ap(iFrame) = - 0.24 * PD(iFrame) - (9.9/mmcm);
    diff_v(iFrame) = - 0.30 * PW(iFrame) - (10.9/mmcm);
    diff_ml(iFrame) = 0.33 * PW(iFrame) + (7.3/mmcm);
    
    % Vector to be subtracted to OPB to find the jc in the pelvis reference frame
    vett_diff_pelvis_sx(:, iFrame) = [ - diff_ml(iFrame);diff_v(iFrame);diff_ap(iFrame)];
    vett_diff_pelvis_dx(:, iFrame) = [diff_ml(iFrame);diff_v(iFrame);diff_ap(iFrame)];

    vett_diff_global_sx(:, iFrame) = pelvis(:, :, iFrame) * vett_diff_pelvis_sx(:, iFrame);
    vett_diff_global_dx(:, iFrame) = pelvis(:, :, iFrame) * vett_diff_pelvis_dx(:, iFrame);
    
    % Compute on the global reference frame
    ca_global_dx(:, iFrame) = OB(:, iFrame) + vett_diff_global_dx(:, iFrame);
    ca_global_sx(:, iFrame) = OB(:, iFrame) + vett_diff_global_sx(:, iFrame);
end

RHJC = ca_global_dx';
LHJC = ca_global_sx';
