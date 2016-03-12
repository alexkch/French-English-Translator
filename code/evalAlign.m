function evalAlign()
%
% evalAlign
%
% Templete file to get output, using all the parts from part 1 through 4
%

%output file
fileOUT_ID = fopen('/h/u4/c2/06/c2changk/csc401/CSC401-a2/code/data/outFILE','w');
    
%credentials
username = '"ab8ed0c1-c0ab-4d60-98f6-55ef0a8e39cc"';
password = '"Owzp3kcvdRLG"';
url = '"https://gateway.watsonplatform.net/language-translation/api/v2/translate"';

%variables
trainDir     = '/u/cs401/A2_SMT/data/Hansard/Training';
testDir      = '/u/cs401/A2_SMT/data/Hansard/Testing';
fn_LME       = 'out_LME';
fn_AM        = 'out_AM';
lm_type      = '';
delta        = 0;
maxIter      = 10;

% references
LinesFr = textread('/u/cs401/A2_SMT/data/Hansard/Testing/Task5.f', '%s', 'delimiter', '\n');
refE = textread('/u/cs401/A2_SMT/data/Hansard/Testing/Task5.e', '%s', 'delimiter', '\n');
refGoogle = textread('/u/cs401/A2_SMT/data/Hansard/Testing/Task5.google.e', '%s', 'delimiter', '\n');

% parameters
sen_len= [1000]; %test_len
%sen_len=[1000, 10000, 15000, 30000]; %
bleu_param = [1,2,3];

% Init our AMs
AMs = struct();

for a=1:length(sen_len)
    AMs.(['AM' num2str(sen_len(a))]) = align_ibm1(trainDir, sen_len(a), maxIter, fn_AM);
end
%AMs.(['AM' num2str(sen_len(1))]) = importdata('/h/u4/c2/06/c2changk/csc401/CSC401-a2/code/real10k');

% Train your language models. This is task 2 which makes use of task 1
%LME = lm_train(trainDir, 'e', fn_LME );
LME = importdata('/h/u4/c2/06/c2changk/csc401/CSC401-a2/code/data/Eng_LM');
vocabSize = length(fieldnames(LME.uni));



% CALCULATION BLUESCORE

fprintf(fileOUT_ID, '::::::::::::::::::::::::::::::::::OUTPUT:::::::::::::::::::::::::::::::::'); 
for lines=1:length(LinesFr)
    
    curl = ['env LD_LIBRARY_PATH='''' curl -u ' username ':' password ' -X POST -F "text=' LinesFr{lines} '" -F "source=fr" -F "target=en" ' url];
    [status, refbluemix] = unix(curl); 
    
    ref1 = preprocess(refE{lines}, 'e');
    ref1 = removeSENT(ref1);
    ref2 = preprocess(refGoogle{lines}, 'e');
    ref2 = removeSENT(ref2);
    ref3 = preprocess(refbluemix, 'e');
    ref3 = removeSENT(ref3);
    
    references = {ref1, ref2, ref3};
    fprintf(fileOUT_ID, '\r\n\r\n_______________________________________________________\r\n'); 
    fprintf(fileOUT_ID, ':::REFERENCES::: \r\n1. E_lines Trans 2. Google Trans 3. Bluemix Trans\r\n');
    for c=1:length(references)
        fprintf(fileOUT_ID, references{c});
        fprintf(fileOUT_ID, '\r\n');
    end
    
    processedFr = preprocess(LinesFr{lines}, 'f');
    processedFr = removeSENT(processedFr);
    
    for num_sent=1:length(sen_len)

        candidate = decode2(processedFr, LME, AMs.(['AM' num2str(sen_len(num_sent))]), lm_type, delta, vocabSize);
        fprintf(fileOUT_ID, '\r\nAM sentence_length: %d\r\n\r\n', sen_len(num_sent));    
        for num=1:length(bleu_param)
            n = bleu_param(num);
            bleu = bleu_score(candidate, references, n);
            fprintf(fileOUT_ID, 'CANDIDATE SENTENCE:  \r\n');
            fprintf(fileOUT_ID, candidate);
            fprintf(fileOUT_ID, '\r\n\r\n');
            fprintf(fileOUT_ID, 'bleu_score @ %d N: %4.7f \r\n', n, bleu);
            fprintf(fileOUT_ID, '\r\n');
            fprintf(fileOUT_ID, '\r\n');            
        end
    end
end
end


% Removes SENTSTART and SENTEND from sentence
function out = removeSENT(sentence)
    
    out = regexprep(sentence, 'SENTSTART\s*', '');
    out = regexprep(out, 'SENTEND\s*', '');

end



