function [participant_ID] = get_participant_id

% Author: SENSOR team
% Date: 29th July 2025
% Released under GNU GPL v3.0: https://www.gnu.org/licenses/gpl-3.0.html
% Open to collaboration—feel free to contact me!

% The purpose of this function is to get the participant ID and wave
while true
    participant_ID = input('Enter Participant ID\n-P for Pilot\n-S for Sensory Group\n-N for Non-sensory Group\nfollowed by 3 digits (e.g., S001):\n', 's');
    
    % Validate Participant ID
    if ~isempty(regexp(participant_ID, '^[PSN]\d{3}$', 'once'))
        break; % Exit loop if ID is valid
    else
        cprintf('*blue','Error: Invalid Participant ID!\nMust start with uppercase P, N or S and have 3-digits\n');
    end
end

% Loop until a valid Wave number is entered
while true
    wave = input('Enter Wave number\n-1 for 3-year-olds,\n-2 for 4-year-olds,\n-3 for 5-year-olds:\n ');
    
    % Validate Wave
    if isscalar(wave) && ismember(wave, [1, 2, 3])
        break; % Exit loop if wave is valid
    else
        cprintf('*red','Error: Invalid Wave number!\n');
    end
end

participant_ID = sprintf('%s_%d_%s', participant_ID, wave, datestr(datetime, 'yyyy_mmm_dd_HH_MM_ss'));

end