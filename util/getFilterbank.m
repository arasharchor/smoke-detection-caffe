function filter_bank = getFilterbank()
    % compute filter bank (Laws' texture energy measures)
    kernel{1} = [1,4,6,4,1]; % L5 = average gray level
    kernel{2} = [-1,-2,0,2,1]; % E5 = edges
    kernel{3} = [-1,0,2,0,-1]; % S5 = spots
    kernel{4} = [1,-4,6,-4,1]; % R5 = ripples
    kernel{5} = [-1,2,0,-2,1]; % W5 = waves
    filter_bank = zeros(5,5,25);
    L = length(kernel);
    for i=1:L
        for j=1:L
            filter_bank(:,:,(i-1)*L+j) = kernel{i}'*kernel{j};
        end
    end
end

