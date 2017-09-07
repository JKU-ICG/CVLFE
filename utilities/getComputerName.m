function name = getComputerName()
% GETCOMPUTERNAME returns the name of the computer (hostname)
% name = getComputerName()
%
% adapted from: m j m a r i n j (AT) y a h o o (DOT) e s


[ret, name] = system('hostname');

if ret ~= 0,
    if ispc
        name = getenv('COMPUTERNAME');
    else
        name = getenv('HOSTNAME');
    end
end
name = strtrim(lower(name));
end
