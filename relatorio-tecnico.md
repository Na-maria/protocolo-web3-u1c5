# Relatorio Tecnico - Protocolo Web3 Completo

**Aluno:** Ana Maria Barros  
**Atividade:** Unidade 1, Capitulo 5  
**Projeto:** Desenvolvimento de Protocolo Web3 Completo com Deploy em Testnet

## Objetivo

Desenvolver um MVP funcional de protocolo descentralizado integrando token ERC-20, NFT ERC-721, staking, governanca simplificada, oraculo Chainlink, scripts Web3 e deploy em testnet Ethereum.

## Problema Resolvido

O protocolo resolve o problema de engajamento e governanca em comunidades digitais. Ele permite que usuarios sejam recompensados com tokens por participacao, recebam NFTs de membership, facam staking para obter recompensas e participem de votacoes por meio de uma DAO simplificada.

## Arquitetura

O sistema e composto por quatro contratos principais: `ProtocoloToken`, `ProtocoloNFT`, `StakingRewards` e `SimpleDAO`.

## Justificativa dos Padroes ERC

O ERC-20 foi utilizado por ser o padrao mais consolidado para tokens fungiveis. Ele e adequado para representar saldos, recompensas e poder de voto. O ERC-721 foi escolhido por representar tokens nao fungiveis, ideais para membership, certificados ou conquistas.

## Implementacao Tecnica

O projeto foi desenvolvido em Solidity `^0.8.24` com Hardhat e OpenZeppelin. O staking calcula recompensas proporcionais ao tempo e ajusta o resultado com base no oraculo ETH/USD.

## Seguranca

Foram aplicados `Ownable`, `ReentrancyGuard`, validacoes com `require`, Solidity `^0.8.x` e bibliotecas OpenZeppelin.

## Integracao com Oraculo

Foi utilizado Chainlink ETH/USD na Sepolia: `0x694AA1769357215DE4FAC081bf1f309aDC325306`.

## Integracao Web3

A integracao Web3 foi feita com `ethers.js` por meio dos scripts `deploy.js` e `interact.js`.

## Deploy em Testnet

Rede utilizada: Sepolia.

- ProtocoloToken: `0x...`
- ProtocoloNFT: `0x...`
- StakingRewards: `0x...`
- SimpleDAO: `0x...`
- Link do explorer: `https://sepolia.etherscan.io/address/0x...`

## Conclusao

O MVP demonstra os principais componentes de um protocolo Web3 moderno: token fungivel, NFT, staking, governanca, oraculo e integracao com scripts Web3.
