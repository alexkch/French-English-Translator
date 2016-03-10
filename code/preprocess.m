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
  outPart = regexp(outSentence, '\((?:.)*\)', 'match');
  outSentence = regexprep(outSentence, '\((?:.)*\)', '(w%)');
  %disp(outPart);
  %disp(outSentence);
  for l=1:length(outPart)
      outPart{l} = regexprep(outPart{l}, '(\w*''*)(\-*\!*\?*\.*)', '$1 $2');
      outPart{l} = regexprep(outPart{l}, '(\-*\!*\?*\.*)(\w*''*)', '$1 $2');
      outPart{l} = regexprep(outPart{l}, '([Dd]'')\s*(\w*)', '$1$2');
      outSentence = regexprep(outSentence, '\(w%\)', outPart{l}, 'once');
  end
      
  outSentence = regexprep(outSentence, '[^a-zA-Z_0-9''\-]', ' $0');
  outSentence = regexprep(outSentence, '([^a-zA-Z_0-9''\-])(\w|''|\-)', '$1 $2');
  outSentence = regexprep(outSentence, '(?:\.(\s)){2,}', '\.\.\. ');
  outSentence = regexprep(outSentence, '(\w)(''){2,}', '$1 $2');
  outSentence = regexprep(outSentence, '(''){2,}(\w)', '$1 $2');
  %disp(outSentence);
  
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
  outSentence = regexprep(outSentence, '\s+', ' '); 
