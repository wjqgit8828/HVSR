function [hvsr] = hvsrVR(t, dt, horz_data1, horz_data2, vert_data)
% Computes the horizontal to vertical spectral ratio (HVSR) using the
% velocity response spectrum (VRS) for three input acceleration histories
% INPUTS:
%   t: array of natural periods in seconds
%   dt: time step of input acceleration histories
%   horz_data1, horz_data2: input acceleration histories for horizontal components
%   vert_data: input acceleration history for vertical component
% OUTPUT:
%   hvsr: array of HVSR values for each natural period

% Get the number of natural periods and the length of the input acceleration history
nt = length(t);
na = length(horz_data1);

% Calculate the VRS for each input acceleration history
vrs_horz1 = VERS(t, dt, horz_data1);
vrs_horz2 = VERS(t, dt, horz_data2);
vrs_vert = VERS(t, dt, vert_data);

% Initialize the HVSR array
hvsr = zeros(nt, 1);

% Find the indices in the natural periods array where T equals 0
ind = find(t == 0);
len = length(ind);

% Compute the HVSR for each natural period
if (len > 0.0)
    % Update vrs_horz1 and vrs_vert values for T = 0
    vrs_horz1(ind) = 0.0;
    vrs_vert(ind) = 1;
    % Calculate HVSR using the updated vrs_horz1 and vrs_vert values
    hvsr = (sqrt(vrs_horz1 .* vrs_horz2)) ./ vrs_vert;
else
    % Calculate HVSR for all other natural periods
    hvsr = (sqrt(vrs_horz1 .* vrs_horz2)) ./ vrs_vert;
end

end
