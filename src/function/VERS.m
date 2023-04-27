function sv = VERS(T, dt, ddy)
% Computes the velocity response spectrum (VRS) for a given input time
% history using the Duhamel integral method
% INPUTS:
%   T: array of natural periods in seconds
%   dt: time step of input acceleration history
%   ddy: input acceleration history
% OUTPUT:
%   sv: array of VRS values for each natural period

% Define damping ratio
h = 0.05;

% Compute the ERS for the given input time history and damping ratio
res = ERES(h, T, dt, ddy);

% Extract the maximum velocity response for each natural period
sv = res(:,1,2);

end
