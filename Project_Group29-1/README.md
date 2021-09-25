# README #

## Group member ##

Dingkun Zhang 517370910261

Wenwen Xu 519370910184

Yifan Shen 519370910170

## Project Name ##

Texas Hold'em Simulator

## CODES ##

The server script is in ``server.m``; the client script for command-line gaming is in ``client.m``; the client script for GUI gaming is in ``main_interface.m``. Other sub-functions include ``announce.m``, ``inform.m``, ``handRank.m``, ``getResponse.m``, and ``num2card.m``.

## USAGE ##

### Server script ###

Run ``server.m`` in matlab IDE, and record the port numbers shown in the command line. In this project, the ports will always be 30001, 30002, 30003, 30004, 30005.

After all clients have been connected, the script will output the server behavior in the command line. For example:
"Announce: player 1 folds"
"Inform player 2: Your hand is 23 45"
etc.

### Command-line gaming ###

***This script is not spam-proof and is only for debugging, undefined input may result in unexpected outputs***

Run ``client.m`` in matlab IDE, and key in the port and userName. After that, key in the commands whenever the script prompts ``"Your turn!"``. The valid commands include:
``call``
``fold``
``allin``
``check``
``bet [int]``

### Interface-gaming ###

Run ``main_interface.m`` in matlab IDE, and key in the port and userName. After that, click on ``call``, ``fold``, ``bet`` buttons, and use the slider to decide the amount of bet. Whenever the GUI prompts ``"Your turn!"``, the user should click on buttons to respond, or the player will be forced to fold their hand due to timeout.

## FUNCTIONS ##

This part will introduce some major functions in the program.

### announce ###

This function will print some texts to all players.

### inform ###

This function will print some texts to one certain player.

### num2card ###

Tranfer numbers to corresponding cards in the table below.

| Face | Spade  | Heart  | Diamond | Club |
|:---: | :-----:| :----: | :-----: | :---:|
| A    | 1 | 14 | 27 | 40 |
| 2    | 2 | 15 | 28 | 41 |
| 3    | 3 | 16 | 29 | 42 |
| 4    | 4 | 17 | 30 | 43 |
| 5    | 5 | 18 | 31 | 44 |
| 6    | 6 | 19 | 32 | 45 |
| 7    | 7 | 20 | 33 | 46 |
| 8    | 8 | 21 | 34 | 47 |
| 9    | 9 | 22 | 35 | 48 |
| 10   | 10| 23 | 36 | 49 |
| J    | 11| 24 | 37 | 50 |
| Q    | 12| 25 | 38 | 51 |
| K    | 13| 26 | 39 | 52 |

### getResponse ###

Prompt a user to give the response (call/fold/bet), and process it to a structure ``response`` with fields ``isFold``, ``isBet``, ``isAllin``, ``isCall``.

### handRank ###

Input seven cards in integers and output the rank of this hand. The higher the rank, the better the hand is.
