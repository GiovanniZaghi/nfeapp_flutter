# Pré-pedido: pendências

Última verificação contra o servidor real (`prosystem.dyndns-work.com:9092`, módulo `TServerAPPnfe`, usuário de teste OSMAR) em 13/10/2026. Atualizado em 15/10/2026 com a resposta do Fabio sobre a tabela de preço.

## Já confirmado no servidor

- Módulo DataSnap: `TServerAPPnfe` (login e endpoints do pré-pedido). Fica em `ApiSession.module`.
- `LoginApp` devolve `CODIGO` (usuário), `EMPRESA`, `FANTASIA`, `DASHBOARD`, `ID_REPR` (representante) e `MULTITAB`. O representante das buscas é o `ID_REPR` (ex.: `pesquisaCliente//96` funciona, `pesquisaCliente//126` não). O app guarda em `repId`.
- `pesquisaCliente/{busca}/{ID_REPR}` devolve só `CODIGO` e `CLIENTE`. Busca vazia devolve todos do representante.
- `RetornaCondPagto/{ID_REPR}` devolve `CODIGO` e `FORMAPAGTO`.
- `PesquisaProd/{busca}/{tabela}` devolve `CODIGO`, `PRODUTO`, `PRCUNIT` (preço com vírgula). O app já lê `PRCUNIT`.
- Quando não há resultado, as APIs devolvem uma linha com `CODIGO` vazio ("CLIENTE NAO LOCALIZADO" / "PRODUTO NAO LOCALIZADO"). O app descarta essa linha.
- Os endpoints de gravação (`IncluirPedido`, `GravaPed1`, `GravaPed2`) **não foram chamados**, para não criar pedido de teste no servidor.
- **Tabela de preço com MULTITAB = T:** o Fabio confirmou (15/10) que não há (ainda) API para listar as tabelas; o representante digita o nome porque a empresa informa qual usar. Mas você pediu que o app exiba todas as tabelas, como no cadastro de produtos do Sagwin (`Cadastro de Produtos > Tabela de Preços`, ex.: CMC30, VIP25, FEVSIM...). Troquei o campo de texto livre por um seletor (`TabelaPrecoField`) que abre uma lista buscando em `PrePedidoRepository.getTabelasPreco()` — hoje essa chamada lança erro "API ainda não foi definida" porque o endpoint não existe. Enquanto isso, o seletor tem um link "Digitar manualmente" para não travar o uso.

## Dados que preciso de você

| # | Pendência | Estado atual | Onde ajustar |
|---|-----------|--------------|--------------|
| 1 | **Endpoint que lista as tabelas de preço cadastradas** (para popular o seletor da tela de pré-pedido, como pedido). Hoje não existe — preciso do nome da rota e do formato do retorno | `PrePedidoRepository.getTabelasPreco()` sempre lança "API ainda não foi definida"; a tela usa "Digitar manualmente" como alternativa | `PrePedidoRepository.getTabelasPreco`, `TabelaPrecoField` |
| 2 | Um usuário com **MULTITAB = F** para testar | O app envia o segmento da tabela vazio (`PesquisaProd/{busca}/`). O servidor responde 200 a essa URL, mas não consegui validar o resultado | `PrePedidoRepository.searchProdutos` e `gravaPed1` |
| 3 | Consulta de crédito do representante: endpoint e JSON | Tela pronta, sempre mostra "API ainda não foi definida". Chaves `DATA`, `PREPEDIDO`, `DESCRICAO`, `DEBITO`, `CREDITO`, `SALDO` são palpite | `PrePedidoRepository.getCreditoRepresentante`, `CreditoLancamento.fromJson` |
| 4 | API de local de entrega (Giovanni vai montar) | Campo digitável, não é enviado | `PrePedidoPage` e `PrePedidoRepository.gravaPed1` |
| 5 | `GravaPed1` precisa receber **contato** (VARCHAR 60), **frete** e **local de entrega** | Campos existem na tela e no `PrePedidoDraft`, mas não vão na URL | `PrePedidoRepository.gravaPed1` |
| 6 | Observações: coluna `VARCHAR(500)` | App limita a 500 caracteres. Acento vira 3 caracteres na URL | `maxLength` em `PrePedidoPage` |
| 7 | O `total` do `GravaPed1` inclui o frete? | Envia `produtos - desconto + frete` | `PrePedidoDraft.totalGeral` |
| 8 | Desconto: a API recebe sempre R$? | Converte % para R$ antes de enviar | `PrePedidoDraft.desconto` |
| 9 | Valor para campos opcionais vazios (pedido do cliente, observação) | Envia `-` | `PrePedidoRepository.gravaPed1` |
| 10 | Busca de cliente por CNPJ: a API devolve CNPJ? Aceita CNPJ no parâmetro? | A resposta não traz CNPJ. O app envia o texto digitado | `PrePedidoRepository.searchClientes` |
| 11 | Precisa de `ConfirmaPed` no final, como o fluxo antigo? | Não chama | `PrePedidoSaveCubit.save` |
| 12 | Ordem dos parâmetros de `GravaPed1` / `GravaPed2` | Segue a ordem do Fabio: empresa, nº pedido, pedido do cliente, representante, cliente, tipo, condição, desconto, observação, total, tabela. `GravaPed2`: representante, nº pedido, produto, quantidade, valor unitário | `PrePedidoRepository.gravaPed1` / `gravaPed2` |
| 13 | O que significa `DASHBOARD` ("FFFFFFF") no login | Ignorado | `LoginModel` |

## Decisão de regra

- **Falha ao gravar um item depois do cabeçalho** (a API não tem rollback). Hoje: o pedido fica gravado parcialmente, a tela trava a edição e mostra "Tentar novamente", que reenvia só os itens que faltam (não chama `IncluirPedido` nem `GravaPed1` de novo). Alternativas: avisar e abandonar, ou criar um endpoint de cancelamento. Ponto de ajuste: `PrePedidoSaveCubit`.

## Atenção: telas antigas

O login agora usa `TServerAPPnfe`. As telas herdadas do e-commerce/comanda (carrinho, comanda, comissão, consulta de produtos, pedidos) continuam chamando `TServerAPPecf` em seus próprios repositórios e podem não funcionar nesse servidor. Não mexi nelas.

## Homologação (Etapa 9, parte manual)

Os testes automatizados (`test/prepedido/prepedido_test.dart`, 19 testes) cobrem totais, validações, URLs, MULTITAB T/F, formato real das respostas, sequência de gravação, falha de item, cabeçalho recusado e queda de rede. Falta, no app real:

- Cliente com e sem resultado na busca (a API já foi consultada, falta ver na tela).
- MULTITAB = T com tabela válida, e MULTITAB = F.
- Cada um dos 12 tipos de recebimento.
- Pedido com um item e com vários.
- Queda de rede real no meio da gravação.
- Validar com o Fabio no ambiente de homologação antes de liberar para o desktop em produção.
