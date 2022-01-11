import { recoverTypedSignature } from '@metamask/eth-sig-util'

window.addEventListener(`load`, () => {

    const $ = (id) => document.getElementById(id);

    let currentAccounts = [];

    $(`connect`).addEventListener(`click`, async () => {
        if (typeof window.ethereum !== `undefined`) {
            try {
                currentAccounts = await window.ethereum.request({ method: `eth_requestAccounts`, });
                $(`wallet`).innerText = currentAccounts[0];
            } catch (e) {
                alert(`Something went wrong with eth_requestAccounts.`);
                $(`wallet`).innerText = `Not Connected.`;
            }
        } else {
            alert(`window.ethereum is undefined. Is the wallet extension installed and active?`);
            $(`wallet`).innerText = `Not Connected.`;
        }
    });

    $(`eth_signTypedData_v3`).addEventListener(`click`, async () => {
        if (currentAccounts.length > 0) {
            try {
                const EIP712Domain = [
                    { name: `name`, type: `string`, },
                    { name: `version`, type: `string`, },
                    { name: `chainId`, type: `uint256`, },
                    { name: `verifyingContract`, type: `address`, },
                    { name: `salt`, type: `bytes32`, },
                ];
                const Echo = [
                    { name: `message`, type: `string`, },
                    { name: `bidder`, type: `Identity`, },
                ];
                const Identity = [
                    { name: `userId`, type: `uint256`, },
                    { name: `wallet`, type: `address`, }
                ];
                const domain = {
                    name: `Safari Wallet Test dApp`,
                    version: `3`,
                    chainId: 1,
                };
                const message = {
                    amount: `Hello World`,
                    bidder: {
                        userId: 1337,
                        wallet: currentAccounts[0],
                    }
                };
                const data = {
                    types: {
                        EIP712Domain,
                        Echo,
                        Identity,
                    },
                    domain,
                    primaryType: `Echo`,
                    message,
                };

                const signature = await window.ethereum.request({
                    method: `eth_signTypedData_v3`,
                    params: [currentAccounts[0], JSON.stringify(data)],
                    from: currentAccounts[0],
                });

                const result = recoverTypedSignature({ data, signature, version: 'V3' }) === currentAccounts[0].toLowerCase()
                alert(result ? 'Signature verified successfully' : `Signature verification failed: ${signature}`)
            } catch (e) {
                console.error(e)
                alert(`Something went wrong with eth_signTypedData_v3.`);
            }
        } else {
            alert(`Please connect a wallet first.`);
        }
    });
    $(`eth_signTypedData_v4`).addEventListener(`click`, async () => {
        if (currentAccounts.length > 0) {
            try {
                const data = {
                    domain: {
                        chainId: 1,
                        name: 'Ether Mail',
                        verifyingContract: '0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC',
                        version: '1',
                    },

                    message: {
                        /*
                         - Anything you want. Just a JSON Blob that encodes the data you want to send
                         - No required fields
                         - This is DApp Specific
                         - Be as explicit as possible when building out the message schema.
                        */
                        contents: 'Hello, Bob!',
                        attachedMoneyInEth: 4.2,
                        from: {
                            name: 'Cow',
                            wallets: [
                                '0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826',
                                '0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF',
                            ],
                        },
                        to: [
                            {
                                name: 'Bob',
                                wallets: [
                                    '0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB',
                                    '0xB0BdaBea57B0BDABeA57b0bdABEA57b0BDabEa57',
                                    '0xB0B0b0b0b0b0B000000000000000000000000000',
                                ],
                            },
                        ],
                    },
                    // Refers to the keys of the *types* object below.
                    primaryType: 'Mail',
                    types: {
                        // TODO: Clarify if EIP712Domain refers to the domain the contract is hosted on
                        EIP712Domain: [
                            { name: 'name', type: 'string' },
                            { name: 'version', type: 'string' },
                            { name: 'chainId', type: 'uint256' },
                            { name: 'verifyingContract', type: 'address' },
                        ],
                        // Not an EIP712Domain definition
                        Group: [
                            { name: 'name', type: 'string' },
                            { name: 'members', type: 'Person[]' },
                        ],
                        // Refer to PrimaryType
                        Mail: [
                            { name: 'from', type: 'Person' },
                            { name: 'to', type: 'Person[]' },
                            { name: 'contents', type: 'string' },
                        ],
                        // Not an EIP712Domain definition
                        Person: [
                            { name: 'name', type: 'string' },
                            { name: 'wallets', type: 'address[]' },
                        ],
                    },
                }
                const signature = await window.ethereum.request({
                    method: `eth_signTypedData_v4`,
                    params: [currentAccounts[0], JSON.stringify(data)],
                    from: currentAccounts[0],
                });

                const result = recoverTypedSignature({ data, signature, version: 'V4' }) === currentAccounts[0].toLowerCase()
                alert(result ? 'Signature verified successfully' : `Signature verification failed: ${signature}`)
            } catch (e) {
                alert(`Something went wrong with eth_signTypedData_v4.`);
            }
        } else {
            alert(`Please connect a wallet first.`);
        }
    });

    $(`call`).addEventListener(`click`, async () => {
        if (currentAccounts.length > 0) {
            try {
                await window.ethereum.request({
                    method: `eth_call`,
                    params: ``,
                    from: currentAccounts[0],
                });
            } catch (e) {
                alert(`Something went wrong with eth_call.`);
            }
        } else {
            alert(`Please connect a wallet first.`);
        }
    });

});