function tact_hist = is_tact_resp_correct(tact_hist, selected)

% Author: James Ives | james.white1@bbk.ac.uk / james.ernest.ives@gmail.com
% Date: 13th May 2025
% Released under GNU GPL v3.0: https://www.gnu.org/licenses/gpl-3.0.html
% Open to collaboration—feel free to contact me!

% Grab the current trial number and correct response
trial_num = tact_hist.current_trial.trial_num;
correct_resp = tact_hist.tracker.correct_resp_hist{trial_num};

% Check this against what was selected and update tact_hist appropriately
if strcmp(correct_resp, selected)
    tact_hist.current_trial.correct_resp = 1;
    tact_hist.current_trial.correct_in_a_row = tact_hist.current_trial.correct_in_a_row + 1;
    tact_hist.tracker.total_correct = tact_hist.tracker.total_correct + 1;
    tact_hist.tracker.correct_hist(trial_num) = 1;
else
    tact_hist.current_trial.correct_resp = 0;
    tact_hist.current_trial.correct_in_a_row = 0;
    tact_hist.tracker.correct_hist(trial_num) = 0;
end

end