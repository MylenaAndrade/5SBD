namespace bazarTemTudo.Domain
{
    public class TempCarga{
      public int Id { get; set; }
      public int Item_pedido_id { get; set; }
      public DateTime Dt_compra { get; set; }
      public DateTime Dt_pagamento { get; set; }
      public string? Email_cliente { get; set; }
      public string? Nome_cliente { get; set; }
      public string? Cpf_cliente { get; set; }
      public string? Tel_cliente { get; set; }
      public string? Sku { get; set; }
      public string? Upc { get; set; }
      public string? Nome_produto { get; set; }
      public int Quant { get; set; }
      public int Preco_item { get; set; }
      public string? Servico_envio { get; set; }
      public string? Endereco_entrega1 { get; set; }
      public string? Endereco_entrega2 { get; set; }
      public string? Endereco_entrega3 { get; set; }
      public string? Cidade_entrega { get; set; }
      public string? Estado_entrega { get; set; }
      public string? Cep { get; set; }
      public string? Pais_entrega { get; set; }
  }
}