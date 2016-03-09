function logProb = lm_prob(sentence, LM, type, delta, vocabSize)
%
%  lm_prob
% 
%  This function computes the LOG probability of a sentence, given a 
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz

  logProb = -Inf;

  % some rudimentary parameter checking
  if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
  elseif nargin == 2
    type = '';
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  end
  if (isempty(type))
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  elseif strcmp(type, 'smooth')
    if (nargin < 5)  
      disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
      return;
    end
    if (delta <= 0) or (delta > 1.0)
      disp( 'lm_prob: you must specify 0 < delta <= 1.0');
      return;
    end
  else
    disp( 'type must be either '''' or ''smooth''' );
    return;
  end

  words = strsplit(' ', sentence);

  % loop through words in the sentence
  for l=1:length(words)
      % if first word
      if l==1
          % count(sentencestart, wt) or bigram (sentencestart, wt) + smoothing
          num = LM.bi.SENTSTARTMARK.words{l} + delta;
          
          % count(sentencestart) or unigram (sentencestart)
          denom = LM.uni.SENTSTARTMARK + delta;
          
          % check if 0/0
          if num == 0 && denom == 0
              logProb = 0;
          else 
              logProb = num/denom;
          end
          
      % if last word
      elseif l == length(words)
          % count(wt, endofsentence) or bigram (wt, endofsentence) + smoothing
          num = (LM.bi.words{l}.SENTENDMARK + delta);
          
          % count(wt-1) or unigram (wt-1) + smoothing
          denom = (LM.uni.words{l-1} + delta*vocabSize);
          
          %check if 0/0
          if num == 0 && denom == 0
              logProb = 0;
          else 
              logProb = logProb * num/denom;
          end
      % rest of the words
      else
          % count(wt-1, wt) or bigram (wt-1, wt) + smoothing
          num = (LM.bi.words{l-1}.words{l} + delta);
          
          % count(wt-1) or unigram (wt-1) + smoothing
          denom = (LM.uni.words{l-1} + delta*vocabSize);
          
          % check if 0/0
          if num == 0 && denom == 0
              logProb = 0;
          else 
              logProb = logProb * num/denom;
          end
      end
  end 
return