% A function where the user inputs an array of integers to represent a hand
% of cards and output the rank of cards in a six-element array.
% 1 to 13 stands for A,2,3...K in Spade; 14 to 26 stands for A,2,3...K in
% Heart, and so on.
% The output is a six-element array, where the first element stands for the
% hand class, and the other five stands for the used cards.
% 9-straight flush; 8-four of a kind; 7-full house; 6-flush; 5-straight;
% 4-three of a kind; 3-two pairs; 2-pair; 1-high card
% Sample input: [2 15 3 12 5 52 43] output: [2 2 2 13 12 5]
% Sample input: [23 24 11 12 52 43 1] output: [5 14 13 12 11 10]

function [handClassStr, usedCards, rank] = handRank(inputHand)
cards = zeros(13, 4);
cards(inputHand) = 1;% put the cards in a 13*4 table
columnSum = sum(cards);
rowSum13 = sum(cards, 2);
cards(14, :) = cards(1, :);
rowSum14 = sum(cards, 2);
% consider Ace as both 1 and 14, which will be used in "straight" determining
handClass = 'high';
doneFlag = false;

for i = 1:4
    for j = 1:9
        if sum(cards(j:j + 4, i)) == 5
            handClass = 'straight flush';
            doneFlag = 1;
            break
        end
    end
end

% four of a kind
if ~doneFlag && logical(sum(rowSum13 == 4))
    handClass = 'four of a kind';
    doneFlag = true;
end

% full house
if ~doneFlag && logical(sum(rowSum13 == 3)) && logical(sum(rowSum13 >= 2) >= 2)
    handClass = 'full house';
    doneFlag = true;
end

% flush
if ~doneFlag && logical(sum(columnSum >= 5))
    handClass = 'flush';
    doneFlag = true;
end

% straight
if ~doneFlag && any(sum(logical([rowSum14(1:5), rowSum14(2:6), rowSum14(3:7), rowSum14(4:8), ...
        rowSum14(5:9), rowSum14(6:10), rowSum14(7:11), rowSum14(8:12), ...
        rowSum14(9:13), rowSum14(10:14)])) == 5)
    handClass = 'straight';
end

% three of a kind
if ~doneFlag && logical(sum(rowSum13 == 3))
    handClass = 'three of a kind';
    doneFlag = true;
end

% two pairs
if ~doneFlag && logical(sum(rowSum13 == 2) >= 2)
    handClass = 'two pairs';
    doneFlag = true;
end

% pair
if ~doneFlag && sum(rowSum13 == 2) == 1
    handClass = 'pair';
    doneFlag = true;
end

switch handClass
    case 'straight flush'
        r=0;
        for i = 1:4
            for j = 9:-1:1
                if sum(cards(j:j + 4, i)) == 5
                    if j>r
                        r=j;
                    end
                    break
                end
            end
        end
        rankInClass = [10, r + 4, r + 3, r + 2, r + 1, r];
    case 'four of a kind'
        r1 = find(rowSum13 == 4, 1, 'last');
        r2 = find(rowSum13 == 1, 1, 'last');
        rankInClass = [9, r1, r1, r1, r1, r2];

    case 'full house'
        r1 = find(rowSum14 == 3, 1, 'last');
        r2 = find(rowSum14 >= 2, 1, 'last');
        if r2 == r1
            r2 = (find(rowSum14 >= 2, 2, 'last'))';
            r2 = fliplr(r2);
            r2 = r2(2);
        end
        rankInClass = [8, r1, r1, r1, r2, r2];
    case 'flush'
        r1 = cards(:, (columnSum >= 5));
        r2 = (find(r1 ~= 0))';
        rankInClass = [7, sort(mod((11+r2(1, 1:5)), 13) + 2, 'descend')];
    case 'straight'
        r = find(sum(logical([rowSum14(1:5), rowSum14(2:6), rowSum14(3:7), rowSum14(4:8), ...
            rowSum14(5:9), rowSum14(6:10), rowSum14(7:11), rowSum14(8:12), ...
            rowSum14(9:13), rowSum14([10, 11, 12, 13, 1])])) == 5, 1, 'last');
        rankInClass = [6, r + 4, r + 3, r + 2, r + 1, r];
    case 'three of a kind'
        r1 = find(rowSum14 == 3, 1, 'last');
        r2 = fliplr((find(rowSum14 == 1, 2, 'last'))');
        rankInClass = [5, r1, r1, r1, r2];
    case 'two pairs'
        r1 = fliplr((find(rowSum14 == 2, 2, 'last'))');
        r2 = find(rowSum14 == 1, 1, 'last');
        rankInClass = [4, r1(1), r1(1), r1(2), r1(2), r2];
    case 'pair'
        r1 = (find(rowSum14 == 2, 1, 'last'))';
        r2 = fliplr((find(rowSum14 == 1, 3, 'last'))');
        rankInClass = [3, r1, r1, r2];
    case 'high'
        r1 = fliplr((find(rowSum14, 5, 'last'))');
        rankInClass = [2, r1];
    otherwise
        disp('Error classifying this hand');
end
handClassStr = string(handClass);
usedCards = rankInClass(2:6);
%rank is an index indicating the rank of a hand, better hand has higher rank.
rank = 15^5 * rankInClass(1) + 15^4 * rankInClass(2) + 15^3 * rankInClass(3) ...
    + 15^2 * rankInClass(4) + 15 * rankInClass(5) + rankInClass(6);