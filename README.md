# Geohash

Geohash is a virtual land project made by Wakanda Labs.

At the beginning, the total supply was only 32 NFTs, and their geohash were single 32 characters in the geohash algorithm (0-9, and 22 letters except 'a', 'i', 'l', 'o'). Each NFT can continue to be divided into 32 sub-NFTs and their URI will be parent's URI concat new alphabet, reciprocating continuously.

We aim to give everyone in the world an opportunity to become a member.

## tokenURI and tokenId 

| Index | tokenURI | tokenId        |
|-------|----------|----------------|
| 0     | 0        | keccak256(0)   |
| 1     | 1        | keccak256(1)   | 
| ...   | ...      | keccak256(...) |
| 31    | z        | keccak256(z)   |
| 32    | 00       | keccak256(00)  |
| 33    | 01       | keccak256(01)  |
| ...   | ...      | keccak256(...) |
| 1023  | zz       | keccak256(zz)  |
| 1024  | 000      | keccak256(000) |
| 1025  | 001      | keccak256(001) |
| ...   | ...      | keccak256(...) |
| 32767 | zzz      | keccak256(zzz) |
| ...   | ...      | keccak256(...) |

## deployment

| network | contract | contract address                           |
|---------|----------|--------------------------------------------|
| rinkeby | Geohash  | 0x7E578ff3C7b6af861A1fd7f662078817CC78515A |
| mumbai  | Geohash  | 0x188cE78bcE46C958Bb287e0A57f5B68C4cC9632a |
| goerli  | Geohash  | 0xc0166C4F87892ac435444730144C949Acd3F642D |

## development path

- [x] geohash core contract
- [ ] geohash web interface
- [ ] provide media embedding services, which can be used as advertising window for owners
- [ ] seamless access to audio and video

## discord

Wakanda+: https://discord.gg/hddy3D2ufY