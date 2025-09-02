function setup_jellyfish_EEG()

% Author: James Ives | james.white1@bbk.ac.uk / james.ernest.ives@gmail.com
% Date: 29th July 2025
% Released under GNU GPL v3.0: https://www.gnu.org/licenses/gpl-3.0.html
% Open to collaboration—feel free to contact me!

ip_host = '10.10.10.42';
port_host = 55513;
ip_amp = '10.10.10.51';

% set default number of tries, and wait between tries
numTries = 50;
tryWait = 5;
curTry = 1;

% Netstation commands return a status flag, which is zero if
% successfully executed. Init this var now
status = nan;

% start searching. Keep trying until max retries is reached
while curTry < numTries && status ~= 0
    
    % Try to connect to NetStation
    try
        [status, ~] = NetStation('Connect', ip_host, port_host);
    catch ERR
        % handle any weird errors gracefully here.
        error('Psychtoolbox Netstation code threw an error:\n\n%s',...
            ERR.message)
    end
    
    % Validate search results.
    if status ~= 0
        fprintf(sprintf('\tConnection failed, try %d of %d...\n',...
            curTry, numTries));
        % wait for x seconds between retries
        WaitSecs(tryWait);
    end
    curTry = curTry + 1;
    
end

if status ~= 0
    error('Failed to connect to NetStation')
end

% Sync NetStation, start recording and send a syncing event
[status, err] = NetStation('Synchronize'); % GetNTP
if status ~= 0
    error('Error during NetStation sync:\n\n\t%s', err)
end

[status, err] = NetStation('StartRecording');
if status ~= 0
    error('Error during NetStation recording start:\n\n\t%s', err)
end

end