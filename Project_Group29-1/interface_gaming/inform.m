function inform(tcpipServer, this, informText)
% Send text to a certain player
fprintf(tcpipServer(this), informText);
fprintf("Inform player %d: ", this);
fprintf(informText);
fprintf("\n");
pause(2); % Avoid data cramming
end