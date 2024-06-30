namespace bazarTemTudo.Domain
{
  public class MovimentacaoEstoque{
    public int Id { get; set; }
    public int Pedido_id { get; set; }
    public int Quant_pedido { get; set; }
    public int Quant_estoque { get; set; }
    public DateTime Dt_movimentacao { get; set; }
    public int Preco_total { get; set; }
  }
}