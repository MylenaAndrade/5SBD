namespace bazarTemTudo.Domain
{
  public class Compras{
    public int Id { get; set; }
    public DateTime Dt_compra { get; set; }
    public string? Sku { get; set; } 
    public int Quant_necessaria { get; set; }
  }
}