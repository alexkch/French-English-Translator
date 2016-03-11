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
bleu_param = [1,2,3]
%AMs = struct()

for index=1:length(num_runs)
    AM = align_ibm1( trainDir, num_runs{index});
% ... TODO: more 

% TODO: a bit more work to grab the English and French sentences. 
%       You can probably reuse your previous code for this  
    DF = dir( '/u/cs401/A2_SMT/data/Hansard/Testing/Task5.f' );
    DE = dir( '/u/cs401/A2_SMT/data/Hansard/Testing/Task5.e' );
    f_lines = textread(DF, '%s','delimiter','\n');
    e_lines = textread(DE, '%s','delimiter','\n');
    
    for sentence=1:length(f_lines)
        for n=1:length(bleu_param)
            eng = decode( f_lines{sentence}, LME, AM);
            actual = e_lines{sentence};
            bleu_score = 
    


% TODO: perform some analysis
% add BlueMix code here 
username = '""';
password = '""';
url = '""';

for 1:
    curl


[status, result] = unix('')