namespace bazarTemTudo.Domain
{
  public class Pedidos{
      public int Id { get; set; }
      public DateTime Dt_compra { get; set; }
      public DateTime Dt_pagamento { get; set; }
      public string? Status_pedido { get; set; }
      public int Preco_total { get; set; }
      public string? Cliente_id { get; set; }
      public int Quant_total { get; set; }
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