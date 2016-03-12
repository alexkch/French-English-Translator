function bleu_score = bleu_score(candidate, references, n)

    candidate_words = strsplit(' ', candidate);
    
    candidate_length = length(candidate_words) - 2; % Subtract SENTSTART & SENTEND
    
    blue_score = struct();
    blue_score.unigram_count = 0;
    blue_score.bigram_count = 0;
    blue_score.trigram_count = 0;
    
    marked_words = struct();
    
    for i=2:length(candidate_words)-1 %to skip start and end in candidate words
        
        for sentence_i=1:length(references) 
            
            ref_words = strsplit(' ', references{sentence_i});
            
            for j=2:length(ref_words)-1 %Assume the reference sentences start with SENTSTART and SENTEND
            
                if strcmpi(candidate_words{i}, ref_words{j}) 
                    if isfield(marked_words, ref_words{j}) == 0 
                        blue_score.unigram_count = blue_score.unigram_count + 1;
                        marked_words.(candidate_words{i}) = struct();
                    end
                    if (i < length(candidate_words) - 1) && (j < length(ref_words) - 1) && (strcmpi(candidate_words{i+1}, ref_words{j+1}))                    
                        if isfield(marked_words.(candidate_words{i}), ref_words{j+1}) == 0 
                            blue_score.bigram_count = blue_score.bigram_count + 1;
                            marked_words.(candidate_words{i}).(candidate_words{i+1}) = struct();
                        end
                        if (i < length(candidate_words) - 2) && (j < length(ref_words) - 2) && (strcmpi(candidate_words{i+2}, ref_words{j+2}))
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
    
        disp('uni');
        disp(blue_score.unigram_count);
        disp('bi');
        disp(blue_score.bigram_count);
        disp('tri');
        disp(blue_score.trigram_count);
    
    if n == 1
        uni_prob = blue_score.unigram_count / (candidate_length); %dont count SENTSTART/SENTEND
        bi_prob = 1;
        tri_prob = 1;
        disp('uni');
        disp(uni_prob);
    end
    if n == 2
        uni_prob = blue_score.unigram_count / (candidate_length);
        bi_prob = blue_score.bigram_count /  (candidate_length - 1); %dont count SENTSTART/SENTEND
        tri_prob = 1;
        disp('uni');
        disp(uni_prob);
        disp('bi');
        disp(bi_prob);
    end
    if n == 3
        uni_prob = blue_score.unigram_count / (candidate_length);
        bi_prob = blue_score.bigram_count /  (candidate_length - 1);
        tri_prob = blue_score.trigram_count / (candidate_length - 2); %dont count SENTSTART/SENTEND
        disp('tri');
        disp(tri_prob);
    end
    
    BPc = penalty(candidate_length, references);  
    bleu_score = BPc * ((uni_prob * bi_prob * tri_prob).^(1 / n));
    
end

function BPc = penalty(candidate_length, references)
    
    smallest = Inf;
    closest_length = 0;
    for i=1:length(references)
        ref_length = length(strsplit(' ', references{i})) - 2; % Subtract START/ENDAssume the reference sentences do not start with SENTSTART and SENTEND
        difference = candidate_length - ref_length;
        if abs(difference) < smallest
            smallest = difference;
            closest_length = ref_length;
        end
    end
    
    brevity = closest_length/ candidate_length; % brev = ref/can
    
    BPc = exp(1 - brevity); % if rev == can, BPc is 0, otherwise it is e^(1-brev)
    disp('BPc');
    disp(BPc);
end
