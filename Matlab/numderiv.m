function chan_deriv = numderiv(chan,Fs,dir)
% Function: compute the forward, backward, or centered difference (numerical
% derivative)

% Input: chan (samples x channels), Fs (sampling rate), dir (-1 = backward,
% 0 = centered, 1 = forward)
% Output: chan_deriv (samples x channels)

% Function dependencies:
%  NONE

%%%%%
% Documented by: Blair Hu 08/08/17
%%%%%

stepsize = 1/Fs;
if dir == -1 % Backward difference
    for i = 2:size(chan,1)
        chan_deriv(i,:) = (chan(i,:) - chan(i-1,:))/stepsize;
    end
    chan_deriv(1,:) = chan_deriv(2,:);
elseif dir == 0 % Central difference
    for i = 2:size(chan,1)-1
        chan_deriv(i,:) = (chan(i+1,:) - chan(i-1,:))/(2*stepsize);
    end
    chan_deriv(1,:) = chan_deriv(2,:);
    chan_deriv(size(chan,1),:) = chan_deriv(size(chan,1)-1,:);
elseif dir == 1 % Forward difference
    for i = 1:size(chan,1)-1
        chan_deriv(i,:) = (chan(i+1,:) - chan(i,:))/stepsize;
    end
    chan_deriv(size(chan,1),:) = chan_deriv(size(chan,1)-1,:);
end
end