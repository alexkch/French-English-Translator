function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
% 
%  This function implements the training of the IBM-1 word alignment algorithm. 
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing 
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a 
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
  global CSC401_A2_DEFNS
  
  AM = struct();
  
  % Read in the training data
  [eng, fre] = read_hansard(trainDir, numSentences);

  % Initialize AM uniformly 
  AM = initialize(eng, fre);

  % Iterate between E and M steps
  for iter=1:maxIter,
    disp(iter)
    AM = em_step(AM, eng, fre);
  end

  % Save the alignment model
  save( fn_AM, 'AM', '-mat'); 

  end





% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(mydir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
  %eng = {};
  %fre = {};

  % TODO: your code goes here.
  
eng = {};
fre = {};

DE = dir( [ mydir, filesep, '*', 'e'] );
DF = dir( [ mydir, filesep, '*', 'f'] );
len = 1;
original = numSentences;
for iFile=1:min(length(DE), length(DF))

  e_lines = textread([mydir, filesep, DE(iFile).name], '%s','delimiter','\n');
  f_lines = textread([mydir, filesep, DF(iFile).name], '%s','delimiter','\n');
  
  if numSentences <= min(length(e_lines), length(f_lines))
      for l=1:numSentences
        eng{len} = strsplit(' ', preprocess(e_lines{l}, 'e'));
        fre{len} = strsplit(' ', preprocess(f_lines{l}, 'f'));      
        len = len+1;
      end
      if original <= len
            return
      end
  else
      for q=1:min(length(e_lines), length(f_lines))
        eng{len} = strsplit(' ', preprocess(e_lines{q}, 'e'));
        fre{len} = strsplit(' ', preprocess(f_lines{q}, 'f'));
        len = len+1;
      end
      numSentences = numSentences - length(e_lines);
  end
end 
end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = {}; % AM.(english_word).(foreign_word)

    AM.SENTSTART.SENSTART = 1;
    
    
    for l=1:length(eng)
        
        english_words = eng{l};
        french_words = fre{l};
        
        
        for k=2:length(english_words)-1
            if isfield(AM, english_words{k}) ~= 1
                AM.(english_words{k}) = struct();
            end
            for j=2:length(french_words)-1
                AM.(english_words{k}).(french_words{j}) = 0;
            end 
        end
    end
    AM.SENTEND.SENTEND = 1;
    en_fields = fieldnames(AM);
    for i=1:length(en_fields)
        fr_fields = fieldnames(AM.(en_fields{i}));
        for j=1:length(fr_fields)
            AM.(en_fields{i}).(fr_fields{j}) = 1/length(fr_fields);
        end
    end
    
end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
  
  % TODO: your code goes here

tcount = struct();
total = struct();
for l=1:length(eng)
    ue = unique(eng{l});
    uf = unique(fre{l});
    for a=1:length(ue)
        for b=1:length(uf)
            if ~isfield(tcount, (ue{a}))
                tcount.(ue{a}) = struct();
            end
            if ~isfield(tcount.(ue{a}), (uf{b}))
                tcount.(ue{a}).(uf{b}) = 0;
            end
        end
        total.(ue{a}) = 0;
    end

end

for l=1:length(eng)
    e_words = eng{l};
    f_words = fre{l};
    E = e_words(2:end-1);
    F = f_words(2:end-1);

    unique_english = unique(E);
    unique_french = unique(F);
    for f=1:length(unique_french)
        denom_c = 0;
        for e=1:length(unique_english)
            if isfield(t.(unique_english{e}), (unique_french{f}))
                p = t.(unique_english{e}).(unique_french{f});
                denom_c = denom_c + p * sum(ismember(f_words, unique_french{f}));   
            end
        end
        for e2=1:length(unique_english)
            if isfield(t.(unique_english{e2}), (unique_french{f}))
                p = t.(unique_english{e2}).(unique_french{f});
            
                if isfield(tcount, (unique_english{e2}))
                    tcount.(unique_english{e2}).(unique_french{f}) = tcount.(unique_english{e2}).(unique_french{f}) + p * sum(ismember(f_words, unique_french{f})) * sum(ismember(e_words, unique_english{e2}))/denom_c;
                    total.(unique_english{e2}) = total.(unique_english{e2}) +  p * sum(ismember(f_words, unique_french{f})) * sum(ismember(e_words, unique_english{e2}))/denom_c;        
                end
            end
        end
    end
   
end
for c=1:length(fieldnames(total))
    e_dom = fieldnames(total);
    for g=1:length(fieldnames(tcount.(e_dom{c})))
        f_dom = fieldnames(tcount.(e_dom{c}));
        t.(e_dom{c}).(f_dom{g}) = tcount.(e_dom{c}).(f_dom{g})/total.(e_dom{c});  
    end
end
end


