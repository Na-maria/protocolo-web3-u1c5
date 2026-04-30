# Protocolo Web3 Completo com Deploy em Testnet

MVP de protocolo descentralizado para a atividade da Unidade 1, Capitulo 5.

## Componentes

- Token ERC-20: `ProtocoloToken.sol`
- NFT ERC-721: `ProtocoloNFT.sol`
- Staking com recompensa: `StakingRewards.sol`
- Governanca simples: `SimpleDAO.sol`
- Oraculo Chainlink ETH/USD na Sepolia
- Scripts Web3 com `ethers.js`

## Arquitetura

```mermaid
flowchart TD
    Usuario[Usuario Web3] --> Script[Script ethers.js]
    Script --> Token[ERC-20 PWT]
    Script --> NFT[ERC-721 Membership]
    Script --> Staking[StakingRewards]
    Script --> DAO[SimpleDAO]
    Staking --> Oracle[Chainlink ETH/USD]
    Staking --> Token
    DAO --> Token
```

## Como Rodar

```bash
npm install
npm run compile
npm test
```

Crie o arquivo `.env` usando `.env.example` como modelo.

Deploy:

```bash
npm run deploy:sepolia
```

Interacao:

```bash
npm run interact:sepolia
```

## Enderecos dos Contratos

Preencher apos deploy:

- ProtocoloToken:
- ProtocoloNFT:
- StakingRewards:
- SimpleDAO:
- Explorer:
