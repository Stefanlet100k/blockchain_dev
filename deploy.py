from tkinter import Place
from brownie import Contract, accounts, config, network, BlackJack


def join_game(address, msg_value, contract):
    contract.play({'from': address, 'value': msg_value})


def deploy(address, min_stake, max_stake, msg_value):
    #account_players = accounts[1]
    #account = accounts.add(config['wallets']['from_key'])
    contract = BlackJack.deploy(min_stake, max_stake, {'from': address, 'value': msg_value})
    print('deployed:\n', contract.gamePhase())
    return contract


def main():
    address_dealer = accounts[0]
    address_player = accounts[1]
    # starting menu
    print('Hello Brownie!')
    print('Options:')
    print('Become a dealer: D/d')
    #print('Join game as player: join: j/J')
    # decision
    dec = input('type in your choice: ')

    # hidden testing option
    if dec.lower() == 't':
        CONTRACT = deploy(address_dealer ,100, 1000, 2000)
        print('Testing...')

    # deploying as dealer
    if dec.lower() == 'd':
        low = input('Min stake for your game(wei): ')
        high = input('High stake for your game(wei): ')
        val = input('Message value (at least 2xhigh stake): ')
        CONTRACT = deploy(address_dealer, low, high, val)
        print('Contract deployed!')

    # enabled for player to join
    print('Game is active you can join!')
    print('Game available stakes:')
    print(CONTRACT.minStake(), 'wei <= stake <=', CONTRACT.maxStake(), 'wei')    
    dec = input('Join game as player: join - j/J: ')

    if dec.lower() == 'j':
        val = input('Pass your bet(wei): ')
        print(join_game(address_player,val, contract=CONTRACT))

    while dec.lower() != 's' and CONTRACT.gamePhase() == 1:
        print('DEALER', CONTRACT.dealerScore())
        print('PLAYER:', CONTRACT.playerScore())
        dec = input('Hit or stay h/s:')

        if dec == 'h':
            CONTRACT.Hit({'from': address_player}).wait(.5)
        elif dec == 's':
            break
    
    CONTRACT.Stay({'from': address_player}).wait(1)
    print('DEALER', CONTRACT.dealerScore())
    print('PLAYER:', CONTRACT.playerScore())
    enum = ['game', 'won', 'lost', 'draw']
    print('PLAYER:', enum[CONTRACT.gameStatus()])


if __name__ == '__main__':
    main()
    