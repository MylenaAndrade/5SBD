namespace bazarTemTudo.Domain
{
  public class ItensPedido{
    public int Id { get; set; }
    public int Pedido_id { get; set; }
    public int Produto_id { get; set; }
	  public int Nome_produto { get; set; }
    public int Quant { get; set; }
    public int Preco_item { get; set; }
  }
}