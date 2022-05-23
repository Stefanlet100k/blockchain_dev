// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract BlackJack {
    // game designed for two players 
    address payable dealer;
    address payable player;
    uint internal playerStake;
    uint public playerScore = 0;
    uint public dealerScore = 0;
    uint public contractBalance = address(this).balance;

    // game parametrers
    uint[] internal cards = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10];
    uint public minStake;
    uint public maxStake;
    enum Phase {pre, intra, post}
    Phase public gamePhase;
    enum Status {game, won, lost, draw}
    Status public gameStatus;

    constructor (uint _minStake, uint _maxStake) payable {
        require(msg.value >= 2 * _maxStake);
        dealer = payable(msg.sender);
        maxStake = _maxStake;
        minStake = _minStake;
        gamePhase = Phase.pre;
    }

    function play() public payable {
        require(msg.value >= minStake, "Unsufficient founds - stake is to low.");
        require(msg.value <= maxStake, "To high stake - check dealers constraints.");
        require(gamePhase == Phase.pre, "Someone is already playing at this table");
        playerStake = msg.value;
        gamePhase = Phase.intra;
        gameStatus = Status.game;
        player = payable(msg.sender);
        dealerScore += cards[random() % cards.length];
    }

    // helper function that returns a big random integer
    function random() internal view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
    }

    function dealerHits() internal {
        while (dealerScore <= 16) {
            dealerScore += cards[random() % cards.length];
        }
        decideWinner();
    }  


    function Hit() public {
        require(gamePhase == Phase.intra, "Game haven't started yet.");
        require(msg.sender == player, "You are not participating in this game");
        playerScore += cards[random() % cards.length];

        if (playerScore > 21) {
            gamePhase = Phase.post;
            gameStatus = Status.lost;
            return;
        }
    }

    function Stay() public {
        require(gamePhase == Phase.intra, "Game haven't started yet.");
        require(msg.sender == player, "You are not participating in this game");
        gamePhase = Phase.post;
        dealerHits();
        }


    function decideWinner() internal {
        require(gameStatus == Status.game && gamePhase == Phase.post);

        if (playerScore > dealerScore) {
            gameStatus == Status.won;
            payable(player).transfer(2 * playerStake);

        } else if (dealerScore > playerScore) {
            gameStatus = Status.lost;
            payable(dealer).transfer(payable(address(this)).balance);

        } else {
            gameStatus = Status.draw;
            payable(player).transfer(playerStake);
            payable(dealer).transfer(payable(address(this)).balance);

        }
    }
}