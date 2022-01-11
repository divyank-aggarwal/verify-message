from eth_account.messages import encode_defunct
from scripts.helpful_scripts import get_account
from brownie import Verify, config, network
from web3 import Web3
from web3.auto import w3


def deploy_verify():
    account = get_account()
    verify = Verify.deploy(
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify", False),
    )
    return verify


def sign_and_check():
    message = "TEST"
    verify = Verify[-1]
    messageHash = Web3.solidityKeccak(["string"], [message])
    messageHashv2 = encode_defunct(messageHash)
    privateKey = config["wallets"]["from_key"]
    signed_message = w3.eth.account.sign_message(messageHashv2, private_key=privateKey)
    tx = verify.verifyData(message, signed_message.signature)
    tx.wait(1)
    print(tx.events)


def main():
    deploy_verify()
    sign_and_check()
