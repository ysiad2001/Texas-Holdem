% The script which simulates a server of a game, including reading inputs
% from clients and sending datas back to them.
clc;
clear;

%% Setup the server and client connections
N = 5;% The number of players
for i = 1:N
    tcpipServer(i, 1) = tcpip('0.0.0.0', 30000+i, 'NetworkRole', 'server');
    % Connect all five clients on their corresponding ports
    tcpipServer(i, 1).InputBuffersize = 100000; 
    tcpipServer(i, 1).OutputBuffersize = 100000;
    tcpipServer(i, 1).Timeout = 10;
    fprintf("connecting at port %d...\n", 30000+i);
    fopen(tcpipServer(i, 1));
    for tries = 1:30 % Try 30 attempts to connect the client
        if tcpipServer(i, 1).BytesAvailable > 0
            break;
        end
        pause(1);
    end
    if tcpipServer(i, 1).BytesAvailable == 0
        fprintf("Connection timeout");
        userName(i, 1) = "Anonymous";
        fclose(tcpipServer(i, 1));
        continue
    end
    pause(1);
    stringRecv = string(fscanf(tcpipServer(i, 1))); % Get the userName
    userName(i, 1) = stringRecv;
    txtSend = "Connected client name: " +stringRecv;
    fprintf(tcpipServer(i, 1), txtSend);
    fprintf("%s", txtSend);
    %t(i,1) = timer;
    %t(i,1).TimerFcn = @(~, ~)serverCallback(tcpipServer(i,1));
    %t(i,1).ExecutionMode = 'fixedRate';
    %start(t(i,1));
end
announceText = "All Connected\n";
announce(tcpipServer, announceText);
for i = 1:N
    announceText = "Player " +num2str(i) + " userName is " +userName(i);
    announce(tcpipServer, announceText);%
end

%% Initiate the game
initialChips = 1000;
bigBlind = 10;
numOfGames = 10;
index = 1:N;

isDealer = zeros(N, 1);
isSB = zeros(N, 1);
isBB = zeros(N, 1);
isFold = zeros(N, 1);
isAllin = zeros(N, 1);
isElim = zeros(N, 1);
hand = [[0, 0]; [0, 0]; [0, 0]; [0, 0];[0,0]];
chips = zeros(N, 1);
hasPassed = zeros(N, 1);
chipsLeftInPot = zeros(N, 1);
rank = zeros(N, 1);
T = table(isDealer, isSB, isBB, isFold, isAllin,isElim, hand, chips, hasPassed, chipsLeftInPot, rank, userName);
for i = 1:N
    T.chips(i) = initialChips;
end

%% Gameplay
for game = 1:numOfGames
    endGameFlag = 0;
    endRoundFlag = 0;
    dealer = next(game, N-1, N,T);
    announceText = "STARTING GAME " +num2str(game);
    announce(tcpipServer, announceText);%
    deck = randperm(52); % randomize a deck
    table = deck(48:52);
    for i = 1:N
        if T.isElim(i) == 0
        T.hand(i, :) = [deck(2 * i), deck(2 * i - 1)];% deal the hand cards
        informText = "Your hand is " +num2str(deck(2 * i)) +" "+ num2str(deck(2 * i - 1));
        inform(tcpipServer, i, informText);
        end
    end
    for round = 1:4
        if endGameFlag
            break
        end

        this = dealer;
        showdownFlag = 0;
        endRoundFlag = 0;
        counter = 0;
        for i = 1:N
            if ~(T.isFold(i) || T.isAllin(i))
                T.hasPassed(i) = 0;
            end
        end

        % initiate this round
        if round == 1 %pre flop
            for i = 1:N
                T.index(i) = i;
                T.isDealer(i) = 0;
                T.isSB(i) = 0;
                T.isBB(i) = 0;
                T.isFold(i) = 0;
                T.isAllin(i) = 0;
                T.hasPassed(i) = 0;
                T.rank(i) = 0;
                T.chipsInPot(i) = 0;
                T.win(i) = 0;
            end
            announce(tcpipServer, "The preflop round!");%
            pot = 1.5 * bigBlind;
            T.isDealer(this) = 1;
            
            this = next(1, this, N,T);
            T.chips(this) = T.chips(this) - bigBlind / 2;
            T.chipsInPot(this) = bigBlind / 2;
            T.isSB(this) = 1;
            announceText = "Player " +num2str(this) + " raises to " +"5" ...
                + " Now Player " +num2str(this) + " has " ...
                + num2str(T.chips(this)) + " chips left ";
            announce(tcpipServer, announceText);
            % Small blind
            
            this = next(1, this, N,T);
            T.chips(this) = T.chips(this) - bigBlind;
            T.isBB(this) = 1;
            announceText = "Player " +num2str(this) + " raises to " +"10"...
                + " Now Player " +num2str(this) + " has " ...
                + num2str(T.chips(this)) + " chips left ";
            announce(tcpipServer, announceText);
            T.chipsInPot(this) = bigBlind;
            T.win(this) = 0;
            currentBet = bigBlind;
            % Big blind
            
            this = next(1, this, N,T);
            isAllin = 0;
            countOfFolds = 0;
            endGameFlag = 0;
            
        elseif round == 2
            this = next(1, dealer, N,T);
            announceText = "The flop round! The three flop cards are: " ...
                +num2str(table(1)) +" "+ num2str(table(2)) +" "+ num2str(table(3));
            announce(tcpipServer, announceText);%
        elseif round == 3
            this = next(1, dealer, N,T);
            announceText = "The turn round! The turn card is: " +num2str(table(4));
            announce(tcpipServer, announceText);%
        elseif round == 4
            this = next(1, dealer, N,T);
            announceText = "The river round! The river card is: " +num2str(table(5));
            announce(tcpipServer, announceText);%
        end

       %% Get response from player and process the result
        while (1)
            if endRoundFlag || endGameFlag
                break
            end
            numOfFolds = 0;
            numOfAllins = 0;
            for i = 1:N
                numOfFolds = numOfFolds + T.isFold(i);
                numOfAllins = numOfAllins + T.isAllin(i);
            end
            if numOfFolds == N - 1 % all player except one folds
                endGameFlag = 1;
                showdownFlag = 1;
                break
            elseif numOfAllins + numOfFolds == N % all players folds or all in
                endGameFlag = 1;
                showdownFlag = 1;
                break
            end

            if T.isFold(this) || T.isAllin(this) || T.isElim(this)
                %this player has already folded or all in
                T.hasPassed(this) = 1;
                this = next(1, this, N,T);
                continue
            elseif T.hasPassed(this) == 1 % all players have passed
                endRoundFlag = 1;
                break
            end

            response = getResponse(tcpipServer, this);

            if response.isFold %this player folds
                T.hasPassed(this) = 1;
                T.isFold(this) = 1;
                announceText = "Player " +num2str(this) + " folds" +" Now Player " +num2str(this) + " has " +num2str(T.chips(this)) + " chips left ";
                announce(tcpipServer, announceText);%
                this = next(1, this, N,T);
                continue

            elseif response.isBet %this player bets

                if response.isCall
                    response.bet = currentBet - T.chipsInPot(this);
                end

                if response.bet == T.chips(this) || response.allin %this player all in
                    response.bet = T.chips(this);
                    T.chipsInPot(this) = T.chipsInPot(this) + response.bet;
                    T.chips(this) = 0;
                    pot = pot + response.bet;
                    T.isAllin(this) = 1;
                    T.hasPassed(this) = 1;

                    if T.chipsInPot(this) > currentBet
                        currentBet = T.chipsInPot(this);
                        for i = 1:N
                            if ~(T.isAllin(i) || T.isFold(i))
                                T.hasPassed(i) = 0; %reset all hasPassed flags
                            end
                        end
                    end
                    announceText = "Player " +num2str(this) + " allin " +num2str(response.bet) + " Now Player " +num2str(this) + " has " +num2str(T.chips(this)) + " chips left ";
                    announce(tcpipServer, announceText);%
                    this = next(1, this, N,T);
                    continue

                elseif response.bet + T.chipsInPot(this) < currentBet
                    informText = "Not enough bet!";
                    inform(tcpipServer,this,informText);
                    continue

                elseif response.bet + T.chipsInPot(this) == currentBet %this player calls
                    T.chipsInPot(this) = T.chipsInPot(this) + response.bet;
                    T.chips(this) = T.chips(this) - response.bet;
                    pot = pot + response.bet;
                    T.hasPassed(this) = 1;
                    announceText = "Player " +num2str(this) + " calls" + " Now Player " +num2str(this) + " has " +num2str(T.chips(this)) + " chips left ";
                    announce(tcpipServer, announceText);%
                    this = next(1, this, N,T);
                    continue

                elseif response.bet + T.chipsInPot(this) > currentBet %this player raises
                    T.chipsInPot(this) = T.chipsInPot(this) + response.bet;
                    T.chips(this) = T.chips(this) - response.bet;
                    pot = pot + response.bet;
                    currentBet = T.chipsInPot(this);
                    for i = 1:N
                        if ~(T.isAllin(i) || T.isFold(i))
                            T.hasPassed(i) = 0; %reset all hasPassed flags
                        end
                    end
                    T.hasPassed(this) = 1;
                    announceText = "Player " +num2str(this) + " raises to " +num2str(currentBet) + " Now Player " +num2str(this) + " has " +num2str(T.chips(this)) + " chips left ";
                    announce(tcpipServer, announceText);
                    this = next(1, this, N,T);
                    continue
                end
            end
        end
    end

    %% Showdown
    if (~endGameFlag) || showdownFlag
        announce(tcpipServer, "Showdown");
        for i = 1:N
            if ~T.isFold(i)
                hand = T.hand(i, :);
                announceText = "Player " +num2str(i) + " hand is " +num2str(hand(1)) +" "+ num2str(hand(2));
                announce(tcpipServer, announceText);
                [handClassStr, usedCards, rank] = handRank([hand, table]);
                announceText = "Player " +num2str(i) + " used cards are " +num2str(usedCards(1)) +" "+  num2str(usedCards(2)) + " "+ num2str(usedCards(3)) + " "+ num2str(usedCards(4)) +" "+  num2str(usedCards(5)) + " "+ "It's a " +handClassStr;
                announce(tcpipServer, announceText);
                T.rank(i) = rank;
            end
        end
        % Announce all ranks of player's hands
        
        rankOfPlayers = zeros(1, N);
        chipsLeftInPot = (T.chipsInPot);
        sidepotDepth = 0;
        while pot > bigBlind
            rankOfPlayers = zeros(1, N);
            for i = 1:N
                if (~T.isFold(i)) && (chipsLeftInPot(i) >= bigBlind)
                    rankOfPlayers(1, i) = T.rank(i);
                    % only players that didn't fold can showdown
                end
            end
            winners = find(rankOfPlayers == max(rankOfPlayers));

            sidepotWinners = [];
            for i = 1:length(winners)
                if chipsLeftInPot(winners(i)) >= bigBlind
                    sidepotWinners = [sidepotWinners, winners(i)];
                end
            end

            sidepotDepth = min(chipsLeftInPot(sidepotWinners));
            sidepot = 0;
            for i = 1:N
                if (chipsLeftInPot(i)) ~= 0
                    if chipsLeftInPot(i) <= sidepotDepth
                        sidepot = sidepot + chipsLeftInPot(i);
                        chipsLeftInPot(i) = 0;
                    elseif chipsLeftInPot(i) > sidepotDepth
                        sidepot = sidepot + sidepotDepth;
                        chipsLeftInPot(i) = chipsLeftInPot(i) - sidepotDepth;
                    end
                end
            end
            
            % Implement the sidepot rules of poker
            pot = pot - sidepot;
            for i = 1:length(sidepotWinners)
                T.win(sidepotWinners(i)) = T.win(sidepotWinners(i)) + sidepot / length(sidepotWinners);
            end
        end
    end
    for i = 1:N
        if T.win(i)
            T.chips(i) = T.chips(i) + T.win(i);
            announceText = "Player " +num2str(i) + " has won a pot of " +num2str(T.win(i)) + "!";
            announce(tcpipServer, announceText);
        end
        announceText = "Player " +num2str(i) + " now has " +num2str(T.chips(i)) + " chips";
        announce(tcpipServer, announceText);
        if T.chips(i) < bigBlind
            announceText = "Player " +num2str(i) + " is eliminated!";
            announce(tcpipServer, announceText);
            T.isElim(i) = 1;
        end
    end
end


function currentPlayer = next(n, currentPlayer, N,T)
% determine the next player
if n == 0
    return
end
if currentPlayer == N
    currentPlayer = 1;
else
    currentPlayer = currentPlayer+1;
end
if T.isElim(currentPlayer)
    currentPlayer = next(n, currentPlayer, N,T);
else
    currentPlayer = next(n-1, currentPlayer, N,T);
end
end


