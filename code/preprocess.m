function outSentence = preprocess( inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation 
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed 
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French) 
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz 

  global CSC401_A2_DEFNS
  
  % first, convert the input sentence to lower-case and add sentence marks 
  inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower( inSentence ) ' ' CSC401_A2_DEFNS.SENTEND];

  % trim whitespaces down 
  inSentence = regexprep(inSentence, '\s+', ' '); 

  % initialize outSentence
  outSentence = inSentence;

  % perform language-agnostic changes
  outSentence = regexprep(outSentence, '[\[\,\:\;\(\)\{\}\<\>\=\]\+\-\\\/]', ' $0');
  outSentence = regexprep(outSentence, '(\w)(\.)', '$1 $2');
  
  switch language
   case 'e'
    outSentence = regexprep(outSentence, '(''[^t])', ' $0');
    outSentence = regexprep(outSentence, '(n''t)', ' $0');
    

   case 'f'    
    outSentence = regexprep(outSentence, '(l'')', '$0 ');
    outSentence = regexprep(outSentence, '([bcfghjkmnpqrstvwxz]'')', '$0 ');
    outSentence = regexprep(outSentence, '(qu'')', '$0 ');
    outSentence = regexprep(outSentence, '(''on)', ' $0');
    outSentence = regexprep(outSentence, '(''il)', ' $0');

  end

  % change unpleasant characters to codes that can be keys in dictionaries
  outSentence = convertSymbols( outSentence );

