%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

% some of your definitions
trainDir     = TODO;
testDir      = TODO;
fn_LME       = TODO;
fn_LMF       = TODO;
lm_type      = TODO;
delta        = TODO;
vocabSize    = TODO; 
numSentences = TODO;

% Train your language models. This is task 2 which makes use of task 1
LME = lm_train( trainDir, 'e', fn_LME );
LMF = lm_train( trainDir, 'f', fn_LMF );

% Train your alignment model of French, given English 
num_runs = [1000, 5000, 10000, 30000];
bleu_param = [1,2,3];

for index=1:length(num_runs)
    AM = align_ibm1( trainDir, num_runs{index});
    
    % hansard references
    DF = dir( '/u/cs401/A2_SMT/data/Hansard/Testing/Task5.f' );
    DE = dir( '/u/cs401/A2_SMT/data/Hansard/Testing/Task5.e' );
    f_lines = textread(DF, '%s','delimiter','\n');
    e_lines = textread(DE, '%s','delimiter','\n');
    
    % google references
    GOOGLE = dir( '/u/cs401/A2_SMT/data/Hansard/Testing/Task5.e' );
    e_lines_google = textread(GOOGLE, '%s','delimiter','\n');
    
    % IBM BlueMix references
    [status, cmdout] = sprintf('curl -u "{username}":"{password}" -X POST -F "text=%s"-F "source=fr" -F "target=en" "https://gateway.watsonplatform.net/language-translation/api/v2/translate"', f_lines{index});
    
    for sentence=1:length(f_lines)
        for n=1:length(bleu_param)
            eng = decode(f_lines{sentence}, LME, AM);
            
            % 3 references
            actual_hansard = e_lines{sentence};
            actual_google = e_lines_googles{sentences};
            actual_ibm = cmdout;
            
            % calculate bleu score
            bleu_score1 = bleu_score();
            bleu_score2 = bleu_score();
            bleu_score3 = bleu_score();
        end
    end
end