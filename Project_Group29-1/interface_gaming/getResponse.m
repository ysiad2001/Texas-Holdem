function response = getResponse(tcpipServer, this)
% Get the response from the player
response.isCall = 0;
response.isBet = 0;
response.isFold = 0;
response.isAllin = 0;
response.bet = 0;
fprintf("Waitin for Player %d to response...\n", this);
fprintf(tcpipServer(this), "getResponse");
for tries = 1:300
    if tcpipServer(this).BytesAvailable > 0
        break
    end
    pause(1);
end
if tcpipServer(this).BytesAvailable == 0
    fprintf("No response");
    response.isFold = 1;
    response.allin = 0;

    return
else
    rawData = string(fscanf(tcpipServer(this)));
end

inputString = split(string(rawData));
switch inputString(1)
    case "call"
        response.isCall = 1;
        response.isBet = 1;
        response.allin = 0;
    case "check"
        response.isBet = 1;
        response.bet = 0;
        response.allin = 0;
    case "raise"
        response.isBet = 1;
        response.bet = str2double(inputString(2));
        response.allin = 0;
    case "bet"
        response.allin = 0;
        response.isBet = 1;
        response.bet = str2double(inputString(2));
    case "allin"
        response.isBet = 1;
        response.allin = 1;
    case "fold"
        response.isFold = 1;
        response.allin = 0;
    otherwise
        response.isFold = 1;
        response.allin = 0;
end
end
