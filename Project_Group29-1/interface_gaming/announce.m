function announce(tcpipServer, announceText)
% Send text to all players
for i = 1:length(tcpipServer)
    fprintf(tcpipServer(i), announceText);
end
fprintf("Announce: ");
fprintf(announceText);
fprintf("\n");
pause(2); % Avoid data cramming
end