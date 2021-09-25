% A script to simulate a client of a game, which uses command-line gaming
% and is only for testing. It is not spam-proof, please refer to README
% for how to use it.
clc;
clear;
command = input("input the command ", 's');
    port = str2double(command);
    tcpipClient = tcpip('0.0.0.0', port, 'NetworkRole', 'client');
    tcpipClient.InputBuffersize = 100000; %127.0.0.1
    tcpipClient.OutputBuffersize = 100000;
    tcpipClient.Timeout = 5; %No idea what this is
    fprintf("connecting at port %d...\n", port);
    fopen(tcpipClient);
    pause(1);
    userName = input("input the user name: ", 's');
    fprintf(tcpipClient, userName);
    t = timer;
    t.TimerFcn = @(~, ~)clientCallBack(tcpipClient);
    t.ExecutionMode = 'fixedSpacing';
    t.Period = 1;
    start(t);

function clientCallBack(tcpipClient)
if tcpipClient.BytesAvailable > 0
    stringRecv = strip(string(fscanf(tcpipClient)));
    if stringRecv == "getResponse"
        fprintf("Your turn!\n");
        txtSend = input("input your response: ", 's');
        fprintf(tcpipClient, txtSend);
    else
        fprintf("%s\n", stringRecv);
    end
end
end