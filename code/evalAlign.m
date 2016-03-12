function evalAlign()
%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

username = '"ab8ed0c1-c0ab-4d60-98f6-55ef0a8e39cc"';
password = '"Owzp3kcvdRLG"';
url = '"https://gateway.watsonplatform.net/language-translation/api/v2/translate"';

trainDir     = '/u/cs401/A2_SMT/data/Hansard/Training';
testDir      = '/u/cs401/A2_SMT/data/Hansard/Testing';
fn_LME       = 'out_LME';
lm_type      = '';
delta        = 0;
maxIter      = 10;

LinesFr = textread('/u/cs401/A2_SMT/data/Hansard/Testing/Task5.f', '%s', 'delimiter', '\n');
refE = textread('/u/cs401/A2_SMT/data/Hansard/Testing/Task5.e', '%s', 'delimiter', '\n');
refGoogle = textread('/u/cs401/A2_SMT/data/Hansard/Testing/Task5.google.e', '%s', 'delimiter', '\n');
sen_len=[1000, 10000, 15000, 30000];
bleu_param = [1,2,3];

AMs = struct();
% Train your alignment model of French, given English 

for a=1:length(sen_len)
    AMs.(['AM' num2str(sen_len(a))]) = align_ibm1(trainDir, sen_len(a), maxIter, f);
end

% Train your language models. This is task 2 which makes use of task 1
LME = lm_train(trainDir, 'e', fn_LME );
vocabSize = length(fieldnames(LMs.LME.uni));

for lines=1:length(LinesFr)
    
    curl = ['curl -u ' username ':' password ' -X POST -F "text=' LinesFr{lines} '" -F "source=fr" -F "target=en" ' url];
    [status, refbluemix] = unix(curl); 
    
    disp('bluemix status [status, reference]');
    disp(status);
    disp(refbluemix);
    
    
    ref1 = preprocess(refE{lines}, 'e');
    ref1 = removeSENT(ref1);
    ref2 = preprocess(refGoogle{lines}, 'e');
    ref2 = removeSENT(ref2);
    ref3 = preprocess(refbluemix, 'e');
    ref3 = removeSENT(ref3);
    
    references = {ref1, ref2, ref3};
    disp('references 1. E_lines Trans 2. Google Trans 3. Bluemix Trans')
    disp(references);
    
    processedFr = preprocess(LinesFr{lines}, 'f');
    
    for num_sent=1:length(sen_len)
        
        candidate = decode2(processedFr, LME, AMs.(['AM' num2str(sen_len(num_sent))]), lm_type, delta, vocabSize);
        
        disp('candidate & references')
        disp(candidate);       
        
        for num=1:length(bleu_param)
            n = bleu_param(num);
            bleu_score = bleu_score(candidate, references, n);
            disp('bleu_score @ n');
            disp(n);
            disp(bleu_score);
        end
    end
end

function out = removeSENT(sentence)
    
    out = regexprep(sentence, 'SENTSTART\s*', '');
    out = regexprep(out, 'SENTEND\s*', '');

end


