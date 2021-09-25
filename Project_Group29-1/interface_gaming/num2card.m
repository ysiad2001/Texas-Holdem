function str = num2card(x)
% Convert 1-52 to their corresponding strings 
suit = floor((x-1)/13);
face = x - suit * 13;
if face == 1
    str = "Ace";
elseif face == 2
    str = "Two";
elseif face == 3
    str = "Three";
elseif face == 4
    str = "Four";
elseif face == 5
    str = "Five";
elseif face == 6
    str = "Six";
elseif face == 7
    str = "Seven";
elseif face == 8
    str = "Eight";
elseif face == 9
    str = "Nine";
elseif face == 10
    str = "Ten";
elseif face == 11
    str = "Jack";
elseif face == 12
    str = "Queen";
elseif face == 13
    str = "King";
end
    
if suit == 0
    str = str + " of spade ";
elseif suit == 1
    str = str + " of heart ";
elseif suit == 2
    str = str + " of diamond ";
elseif suit == 3
    str = str + " of club ";
end
end