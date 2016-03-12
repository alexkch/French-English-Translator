
function bleu_score = bleu_score(candidate, references, n)
%
%
%  This function returns a bleu_score based on the candidate sentence
%  and reference sentences and calculates it from this. See lecture 6-1 for more details
%
%  INPUTS:
%
%       candidate    	: (string) a preprocessed sentence
%       references      : (array of strings) reference sentences for the candidate      
%       n        	: 1 <= n <= 3   
%
% 
% By Alex Chang (Kao-Tsun Chang)     

    candidate_words = strsplit(' ', candidate);
    
    candidate_length = length(candidate_words); 
    
    %data count for 
    blue_score = struct();
    blue_score.unigram_count = 0;
    blue_score.bigram_count = 0;
    blue_score.trigram_count = 0;
    
    % for tracking words that have already appeared in at least one reference sentence
    marked_words = struct();
    
    for i=1:length(candidate_words) % The sentence does not start with SENTSTART nor ends with SENTEND, we dont have to account for it
        
        for sentence_i=1:length(references) 
            
            ref_words = strsplit(' ', references{sentence_i});
            
            for j=1:length(ref_words)  % The sentence does not start with SENTSTART nor ends with SENTEND, we dont have to account for it
                
                % if candidate word is in the ref sentence, increment uni
                % count
                if strcmpi(candidate_words{i}, ref_words{j}) 
                    % mark it in marked_words as already counted
                    if isfield(marked_words, ref_words{j}) == 0 
                        blue_score.unigram_count = blue_score.unigram_count + 1;
                        marked_words.(candidate_words{i}) = struct();
                    end
                    %if candidate word k and k+1 are both in reference
                    %sentence, increment bi
                    if (i < length(candidate_words)) && (j < length(ref_words)) && (strcmpi(candidate_words{i+1}, ref_words{j+1}))                    
                        % mark k.k+1 as a field in marked_words
                        if isfield(marked_words.(candidate_words{i}), ref_words{j+1}) == 0 
                            blue_score.bigram_count = blue_score.bigram_count + 1;
                            marked_words.(candidate_words{i}).(candidate_words{i+1}) = struct();
                        end
                        %if candidate word k, k+1 and k+2 are both in reference
                        %sentence, increment tri
                        if (i < length(candidate_words) - 1) && (j < length(ref_words) - 1) && (strcmpi(candidate_words{i+2}, ref_words{j+2}))
                            % mark k.k+1.k+2 as a field in marked words
                            if isfield(marked_words.(candidate_words{i}), ref_words{j+1}) == 0 
                                blue_score.trigram_count = blue_score.trigram_count + 1;
                                marked_words.(candidate_words{i}).(candidate_words{i+1}).(candidate_words{i+1}) = 1;
                            end
                        end
                    end
                end
            end
        end
    end
    
    
    % the different options for n
    if n == 1
        uni_prob = blue_score.unigram_count / (candidate_length); 
        bi_prob = 1;
        tri_prob = 1;

    end
    if n == 2
        uni_prob = blue_score.unigram_count / (candidate_length);
        bi_prob = blue_score.bigram_count /  (candidate_length - 1); 
        tri_prob = 1;

    end
    if n == 3
        uni_prob = blue_score.unigram_count / (candidate_length);
        bi_prob = blue_score.bigram_count /  (candidate_length - 1);
        tri_prob = blue_score.trigram_count / (candidate_length - 2); 

    end
    
    BPc = penalty(candidate_length, references);  
    bleu_score = BPc * ((uni_prob * bi_prob * tri_prob).^(1 / n));
    
end

function BPc = penalty(candidate_length, references)
%
%
%  This function calculates the penalty BPc from candidate length and references
%
%  INPUTS:
%
%       candidate_length	: length of candidate sentence
%       references      	: (array of strings) reference sentences for the candidate      
%
% 
% By Alex Chang (Kao-Tsun Chang)     

    %set smallest to Inf
    smallest = Inf;
    
    %set closest length to 0
    closest_length = 0;
    for i=1:length(references)
        ref_length = length(strsplit(' ', references{i})); % ref sentences do not start with SENTSTART and SENTEND
        difference = candidate_length - ref_length;
        if abs(difference) < smallest
            smallest = difference;
            closest_length = ref_length;
        end
    end
    
    brevity = closest_length/ candidate_length; % brev = ref/can
    
    BPc = exp(1 - brevity); % if rev == can, BPc is 0, otherwise it is e^(1-brev)

end
