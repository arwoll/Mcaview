function string_array = tokenize(line, item)
% string_array = tokenize(line) takes a string line and parses it into a
% cell array. Written for openmca in woll@sophie:Chess/Mass/Matlab
[T, line] = strtok(line);
n = 1;
while ~isempty(T)
    string_array(n) = {T}; % Creates a cell array to handle different-length strings
    n=n+1;
    [T,line] = strtok(line);
end

% If only one item is desired, we'll also convert it to a char type
if nargin == 2 && item <= n
    string_array = char(string_array(item));
end